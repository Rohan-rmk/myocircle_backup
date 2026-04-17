// patient_survey_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/api_service.dart';
import '../../providers/session_provider.dart';
import '../../main.dart'; // for BridgeScreen (keep if you use it here)

const Color backgroundColor = Color(0xFFF7FAFC);
const Color textColor = Color(0xFF2D3748);
const Color gray200 = Color(0xFFE2E8F0);
const Color gray300 = Color(0xFFCBD5E0);
const Color gray600 = Color(0xFF4A5568);
const Color gray700 = Color(0xFF2D3748);
const Color white = Color(0xFFFFFFFF);
const Color teal600 = Color(0xFF319795);
const Color teal700 = Color(0xFF2C7A7B);

class FeedbackQuestion {
  final int feedbackMasterId;
  final String feedbackQuestion;
  final String feedbackLabel;
  final List<FeedbackOption> options;

  FeedbackQuestion({
    required this.feedbackMasterId,
    required this.feedbackQuestion,
    required this.feedbackLabel,
    required this.options,
  });

  factory FeedbackQuestion.fromJson(Map<String, dynamic> json) {
    return FeedbackQuestion(
      feedbackMasterId: (json['feedbackmasterid'] is int)
          ? json['feedbackmasterid']
          : int.tryParse(json['feedbackmasterid'].toString()) ?? 0,
      feedbackQuestion: json['feedbackquestion']?.toString() ?? '',
      feedbackLabel: json['feedbacklabel']?.toString() ?? '',
      options: (json['options'] as List<dynamic>? ?? [])
          .map((o) => FeedbackOption.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FeedbackOption {
  final String option;
  final int optionScore;

  FeedbackOption({
    required this.option,
    required this.optionScore,
  });

  factory FeedbackOption.fromJson(Map<String, dynamic> json) {
    return FeedbackOption(
      option: json['option']?.toString() ?? '',
      optionScore: (json['optionscore'] is int)
          ? json['optionscore']
          : int.tryParse(json['optionscore'].toString()) ?? 0,
    );
  }
}

/// Screen: PatientSurveyScreen
/// - Shows a selection list if multiple family members have feedbackQuestions
/// - Otherwise shows the questionnaire directly
class PatientSurveyScreen extends StatefulWidget {
  final bool isBaseline;

  const PatientSurveyScreen({Key? key, this.isBaseline = true})
      : super(key: key);

  @override
  State<PatientSurveyScreen> createState() => _PatientSurveyScreenState();
}

class _PatientSurveyScreenState extends State<PatientSurveyScreen> {
  // Questions currently being shown
  List<FeedbackQuestion> _questions = [];
  // Answers keyed by feedbackLabel -> optionScore
  Map<String, int?> _answers = {};
  bool _isLoading = false;

  // Selection mode variables
  bool _showSelection = false;
  List<Map<String, dynamic>> _eligibleMembers = [];

  // Currently targeted member id (profileId/patientId) for submission
  dynamic _targetPatientId;

  @override
  void initState() {
    super.initState();
    _prepareScreen();
  }

  void _prepareScreen() {
    final sessionProvider =
        Provider.of<SessionProvider>(context, listen: false);
    final userData = sessionProvider.userData;

    // Try to extract familyMembers as list of maps
    final familyMembersRaw = userData?['familyMembers'];
    List<Map<String, dynamic>> familyMembers = [];

    if (familyMembersRaw is List) {
      for (var item in familyMembersRaw) {
        if (item is Map<String, dynamic>) familyMembers.add(item);
      }
    }

    // If no familyMembers present, fallback to legacy 'feedbackQuestions' in root userData
    if (familyMembers.isEmpty) {
      final topLevelQuestions =
          userData?['feedbackQuestions'] as List<dynamic>?;
      if (topLevelQuestions != null) {
        _initializeQuestionsFromJson(topLevelQuestions);
        _showSelection = false;
      } else {
        // No questions available
        _questions = [];
        _showSelection = false;
      }
      return;
    }

    // Filter members that have non-null feedbackQuestions
    _eligibleMembers = familyMembers
        .where((m) =>
            m.containsKey('feedbackQuestions') &&
            m['feedbackQuestions'] != null)
        .cast<Map<String, dynamic>>()
        .toList();

    // If only one member in familyMembers OR only one eligible member -> open directly
    if (familyMembers.length == 1 || _eligibleMembers.length <= 1) {
      if (_eligibleMembers.isNotEmpty) {
        final member = _eligibleMembers.first;
        final questionsJson = (member['feedbackQuestions'] as List<dynamic>);
        _targetPatientId = _extractPatientId(member);
        _initializeQuestionsFromJson(questionsJson);
      } else {
        // nothing to show
        _questions = [];
      }
      _showSelection = false;
      return;
    }

    // More than one eligible member -> show selection UI
    _showSelection = true;
  }

  void _initializeQuestionsFromJson(List<dynamic> feedbackQuestionsData) {
    _questions = feedbackQuestionsData
        .map((e) => FeedbackQuestion.fromJson(e as Map<String, dynamic>))
        .toList();

    _answers = {};
    for (var q in _questions) {
      _answers[q.feedbackLabel] = null;
    }
    setState(() {});
  }

  dynamic _extractPatientId(Map<String, dynamic> member) {
    return member['profileId'] ??
        member['patientId'] ??
        member['id'] ??
        member['profile_id'] ??
        member['patient_profile_id'];
  }

  bool _isChild(Map<String, dynamic> member) {
    if (member.containsKey('isChild') && member['isChild'] == true) return true;
    final rel = (member['relationship'] ?? '').toString().toLowerCase();
    if (rel == 'child' || rel == 'son' || rel == 'daughter') return true;
    if (member.containsKey('age')) {
      final ageRaw = member['age'];
      final age = int.tryParse(ageRaw?.toString() ?? '');
      if (age != null && age < 18) return true;
    }
    return false;
  }

  void _onSelectMember(int index) {
    final member = _eligibleMembers[index];
    final questionsJson = (member['feedbackQuestions'] as List<dynamic>);
    _targetPatientId = _extractPatientId(member);
    _initializeQuestionsFromJson(questionsJson);
    setState(() {
      _showSelection = false;
    });
  }

  void _onAnswerChange(String label, int score) {
    setState(() {
      _answers[label] = score;
    });
  }

  bool get _isComplete {
    if (_answers.isEmpty) return false;
    return _answers.values.every((v) => v != null);
  }

  Future<void> _handleSubmit() async {
    if (!_isComplete) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final sessionProvider =
          Provider.of<SessionProvider>(context, listen: false);

      final userToken = sessionProvider.userData?['user_token'] ??
          sessionProvider.userData?['userToken'];

      final fallbackPatientId = sessionProvider.userData?['profileId'] ??
          sessionProvider.userData?['patientId'];

      final patientIdToUse = _targetPatientId ?? fallbackPatientId;

      if (userToken == null || patientIdToUse == null) {
        throw Exception('Missing user token or patient/profile id');
      }

      // Prepare feedback submission data
      final List<Map<String, dynamic>> feedbacks = [];
      for (var question in _questions) {
        final ans = _answers[question.feedbackLabel];
        if (ans != null) {
          final selectedOption = question.options.firstWhere(
            (opt) => opt.optionScore == ans,
            orElse: () => question.options.first,
          );

          feedbacks.add({
            'feedback_question_id': question.feedbackMasterId,
            'feedback_label': question.feedbackLabel,
            'option_label': selectedOption.option,
            'option_score': selectedOption.optionScore,
          });
        }
      }

      final response = await ApiService.saveFeedback(
        context: context,
        userToken: userToken,
        patientId: patientIdToUse,
        feedbackType: widget.isBaseline ? 'baseline' : 'monthly',
        feedbacks: feedbacks,
      );

      setState(() {
        _isLoading = false;
      });

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isBaseline
                ? 'Baseline questionnaire submitted successfully!'
                : 'Monthly check-in submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // 🔥 NEW LOGIC — remove this member from eligible list
        _eligibleMembers.removeWhere((m) {
          final id = _extractPatientId(m);
          return id.toString() == patientIdToUse.toString();
        });

        // 🔄 Clear this member's questions so they don't reappear
        setState(() {
          _questions = [];
          _answers.clear();
        });

        // ⏳ Delay for showing success
        await Future.delayed(const Duration(milliseconds: 700));

        // 🧠 If there are still members with pending feedback → return to selection screen
        if (_eligibleMembers.isNotEmpty) {
          setState(() {
            _showSelection = true;
            _targetPatientId = null;
          });
          return;
        }

        // 🎉 If all completed → navigate to BridgeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BridgeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: ${response['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting feedback: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildHeader() {
    return Row(
      children: [
        
        const SizedBox(width: 8),
        Text(
          'Patient Questionnaire',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionUI() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      child: Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)
          ],
          border: Border.all(color: gray200),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select patient to fill questionnaire',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: gray700,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _eligibleMembers.length,
                itemBuilder: (context, index) {
                  final member = _eligibleMembers[index];
                  final bgColor = (index % 2 == 0)
                      ? const Color(0xff1F8C85) // even
                      : const Color(0xff3197DB); // odd

                  final displayName = member['userProfileName'] ??
                      member['profileName'] ??
                      member['patientName'] ??
                      member['name'] ??
                      'Patient ${index + 1}';

                  final isChild = _isChild(member);

                  return GestureDetector(
                    onTap: () => _onSelectMember(index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isChild ? Icons.child_care_rounded : Icons.person,
                            color: white,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionnaireUI() {
    if (_questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              'Loading questions...',
              style: GoogleFonts.inter(fontSize: 16, color: gray600),
            ),
          ],
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      child: Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)
          ],
          border: Border.all(color: gray200),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isBaseline ? "Baseline Questionnaire" : "Monthly Check-in",
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: teal700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isBaseline
                  ? "Please answer the following questions to establish a starting point for your therapy."
                  : "Please answer these to update your monthly progress.",
              style: GoogleFonts.inter(fontSize: 14, color: gray600),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final q = _questions[index];
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 120 + index * 40),
                    margin: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. ${q.feedbackQuestion}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: gray700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: q.options.map((opt) {
                            final isSelected =
                                _answers[q.feedbackLabel] == opt.optionScore;
                            return ChoiceChip(
                              label: Text(opt.option),
                              selected: isSelected,
                              onSelected: (sel) {
                                _onAnswerChange(
                                    q.feedbackLabel, opt.optionScore);
                              },
                              backgroundColor: white,
                              selectedColor: teal600,
                              labelStyle: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected ? white : gray600,
                              ),
                              side: BorderSide(
                                  color: isSelected ? teal600 : gray300,
                                  width: 1.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: gray200),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _isComplete ? _handleSubmit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: teal600,
                        foregroundColor: white,
                        disabledBackgroundColor: gray300,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                      ),
                      child: Text(
                        widget.isBaseline
                            ? "Submit Baseline"
                            : "Submit Check-in",
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Expanded(
                child:
                    _showSelection ? _buildSelectionArea() : _buildMainArea(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionArea() {
    // container that holds selection UI
    return _buildSelectionUI();
  }

  Widget _buildMainArea() {
    // either questionnaire or loading/no-questions message
    if (_questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.question_mark, size: 48, color: gray300),
            const SizedBox(height: 12),
            Text('No questionnaire available',
                style: GoogleFonts.inter(fontSize: 16, color: gray600)),
            const SizedBox(height: 8),
            Text('If you think this is an error, please contact support.',
                style: GoogleFonts.inter(fontSize: 13, color: gray600)),
          ],
        ),
      );
    }
    return _buildQuestionnaireUI();
  }
}