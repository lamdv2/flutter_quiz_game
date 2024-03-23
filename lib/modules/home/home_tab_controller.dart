import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getx_base/models/questions/questions_model.dart';
import 'package:flutter_getx_base/models/questions/quiz_history_model.dart';
import 'package:flutter_getx_base/modules/main/home_controller.dart';
import 'package:flutter_getx_base/modules/message/message.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeTabController extends GetxController
    with GetSingleTickerProviderStateMixin {
  TextEditingController searchHomeController = TextEditingController();
  final HomeController homeController = Get.find();
  final MessageController messageController = Get.put(MessageController());

  final listQuestions = Rxn<List<Question>>();
  final numbQuestion = RxInt(0);
  final numbCorrectAnswer = RxInt(0);
  final isCheckFinish = RxBool(false);
  final isCheckChoose = RxBool(false);
  final isCheckCorrect = RxInt(0);
  final listAnswers = Rxn<List<String>>();

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  void fetchData() async {
    try {
      final dio = Dio();
      final response = await dio.get('https://opentdb.com/api.php?amount=10');
      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        final List<Question> questions =
            results.map((data) => Question.fromJson(data)).toList();
        listQuestions.value = questions;
        List<String> answers = [
          listQuestions.value?[numbQuestion.value].correctAnswer ?? '',
          listQuestions.value?[numbQuestion.value].incorrectAnswers?[0] ?? '',
          listQuestions.value?[numbQuestion.value].incorrectAnswers?[1] ?? '',
          listQuestions.value?[numbQuestion.value].incorrectAnswers?[2] ?? '',
        ];

        answers.shuffle();

        listAnswers.value = answers;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void fetchDataTrueFalseQuestion() async {
    try {
      final dio = Dio();
      final response =
          await dio.get('https://opentdb.com/api.php?amount=10&type=boolean');
      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        final List<Question> questions =
            results.map((data) => Question.fromJson(data)).toList();
        final List<Question> trueFalseQuestions =
            questions.where((question) => question.type == 'boolean').toList();

        listQuestions.value = trueFalseQuestions;

        if (listQuestions.value != null && listQuestions.value!.isNotEmpty) {
          List<String> answers = [
            listQuestions.value![numbQuestion.value].correctAnswer ?? '',
            listQuestions.value![numbQuestion.value].incorrectAnswers?[0] ?? '',
          ];
          answers.shuffle();
          listAnswers.value = answers;
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void fetchDataChooseQuestion() async {
    try {
      final dio = Dio();
      final response =
          await dio.get('https://opentdb.com/api.php?amount=10&type=multiple');
      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        final List<Question> questions =
            results.map((data) => Question.fromJson(data)).toList();
        final List<Question> chooseQuestions =
            questions.where((question) => question.type == 'multiple').toList();

        listQuestions.value = chooseQuestions;

        if (listQuestions.value != null && listQuestions.value!.isNotEmpty) {
          List<String> answers = [
            listQuestions.value![numbQuestion.value].correctAnswer ?? '',
            listQuestions.value![numbQuestion.value].incorrectAnswers?[0] ?? '',
            listQuestions.value![numbQuestion.value].incorrectAnswers?[1] ?? '',
            listQuestions.value![numbQuestion.value].incorrectAnswers?[2] ?? '',
          ];
          answers.shuffle();
          listAnswers.value = answers;
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void finishQuestion() {
    isCheckFinish.value = true;
    saveHistoryGame();
    messageController.getHistoryFromSharedPreferences();
  }

  Future<void> saveHistoryGame() async {
    try {
      DateTime currentTime = DateTime.now();

      QuizHistory history = QuizHistory(numbCorrectAnswer.value, currentTime);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> historyStrings = prefs.getStringList('quizHistory') ?? [];
      historyStrings.add(json.encode(history.toJson()));
      await prefs.setStringList('quizHistory', historyStrings);
    } catch (e) {
      print('Error saving history: $e');
    }
  }

  void newQuizGame() {
    numbQuestion.value = 0;
    numbCorrectAnswer.value = 0;
    isCheckFinish.value = false;
    isCheckChoose.value = false;
    isCheckCorrect.value = 0;
    fetchData();
  }

  void viewHistory() {
    homeController.bottomNavIndex.value = 2;
  }

  void nextQuestion() {
    numbQuestion.value += 1;
    isCheckCorrect.value = 0;
    isCheckChoose.value = false;

    if (listQuestions.value != null &&
        listQuestions.value!.isNotEmpty &&
        listQuestions.value!.length > numbQuestion.value) {
      if (listQuestions.value![numbQuestion.value].type == "multiple") {
        List<String> answers = [
          listQuestions.value![numbQuestion.value].correctAnswer ?? '',
          listQuestions.value![numbQuestion.value].incorrectAnswers?[0] ?? '',
          listQuestions.value![numbQuestion.value].incorrectAnswers?[1] ?? '',
          listQuestions.value![numbQuestion.value].incorrectAnswers?[2] ?? '',
        ];

        answers.shuffle();
        listAnswers.value = answers;
      } else {
        List<String> answers = [
          listQuestions.value![numbQuestion.value].correctAnswer ?? '',
          listQuestions.value![numbQuestion.value].incorrectAnswers?[0] ?? '',
        ];

        answers.shuffle();
        listAnswers.value = answers;
      }
    } else {
      fetchData();
    }
  }

  void isCheckCorrectAnswer(String answer) {
    isCheckChoose.value = true;
    if (answer == listQuestions.value?[numbQuestion.value].correctAnswer) {
      isCheckCorrect.value = 1;
      numbCorrectAnswer.value += 1;
    } else {
      isCheckCorrect.value = 2;
    }
  }
}
