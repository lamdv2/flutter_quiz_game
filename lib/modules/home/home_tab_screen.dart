// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_getx_base/app_controller.dart';
import 'package:flutter_getx_base/shared/constants/app_style.dart';
import 'package:flutter_getx_base/shared/utils/size_utils.dart';
import 'package:flutter_getx_base/theme/theme_helper.dart';
import 'package:get/get.dart';

import '../../shared/constants/colors.dart';
import 'home_tab_controller.dart';

class HomeTabScreen extends GetView<HomeTabController> {
  final AppController appController = Get.find();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: appController.isDarkModeOn.value
                ? ColorConstants.darkBackground
                : ColorConstants.lightBackground,
            extendBody: true,
            resizeToAvoidBottomInset: true,
            body: Padding(
              padding: EdgeInsets.all(getSize(20)),
              child: SingleChildScrollView(
                child: Obx(
                  () => controller.listQuestions.value != null &&
                          controller.listQuestions.value?.length != 0
                      ? controller.isCheckFinish.value
                          ? ResultWidget(
                              controller: controller,
                            )
                          : QuizGameWidget(controller: controller)
                      : Center(
                          child: CircularProgressIndicator(),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ResultWidget extends StatelessWidget {
  const ResultWidget({
    super.key,
    required this.controller,
  });

  final HomeTabController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            "Request",
            style: AppStyles.black000Size20Fw700FfNunito,
          ),
        ),
        SizedBox(
          height: getSize(32),
        ),
        Text(
          "You answered ${controller.numbCorrectAnswer.value} questions correctly",
          style: AppStyles.black000Size18Fw600FfNunito,
        ),
        SizedBox(
          height: getSize(64),
        ),
        ElevatedButton(
          onPressed: () => controller.newQuizGame(),
          child: Text(
            "New game",
            style: AppStyles.black000Size14Fw600FfNunito,
          ),
        ),
        SizedBox(
          height: getSize(32),
        ),
        ElevatedButton(
          onPressed: () => controller.viewHistory(),
          child: Text(
            "View history",
            style: AppStyles.black000Size14Fw600FfNunito,
          ),
        )
      ],
    );
  }
}

class QuizGameWidget extends StatelessWidget {
  const QuizGameWidget({
    super.key,
    required this.controller,
  });

  final HomeTabController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${controller.numbQuestion.value + 1}/${controller.listQuestions.value?.length ?? 0}",
                style: AppStyles.black000Size20Fw700FfNunito,
              ),
              Text(
                "Quiz",
                style: AppStyles.black000Size20Fw700FfNunito,
              ),
              Container(
                child: Text(
                  "${controller.listQuestions.value?[controller.numbQuestion.value].difficulty}",
                  style: AppStyles.black000Size14Fw600FfNunito
                      .copyWith(color: appTheme.amberA600),
                ),
              )
            ],
          ),
          SizedBox(
            height: getSize(32),
          ),
          Center(
            child: Text(
              "${controller.listQuestions.value?[controller.numbQuestion.value].question}",
              style: AppStyles.black000Size18Fw600FfNunito,
            ),
          ),
          SizedBox(
            height: getSize(32),
          ),
          controller.listQuestions.value != null &&
                  controller.listQuestions.value?.length != 0
              ? controller.listQuestions.value![controller.numbQuestion.value]
                          .type ==
                      "multiple"
                  ? AnswersWidget(controller: controller)
                  : AnswersTrueFalseWidget(controller: controller)
              : SizedBox.shrink(),
          SizedBox(
            height: getSize(32),
          ),
          Center(
            child: controller.isCheckCorrect.value == 0
                ? Text(
                    "",
                  )
                : controller.isCheckCorrect.value == 1
                    ? Text(
                        "Correct",
                        style: AppStyles.black000Size20Fw700FfNunito.copyWith(
                          color: appTheme.green300,
                        ),
                      )
                    : Text(
                        "Wrong",
                        style: AppStyles.black000Size20Fw700FfNunito.copyWith(
                          color: appTheme.red300,
                        ),
                      ),
          ),
          SizedBox(
            height: getSize(48),
          ),
          Center(
            child: ElevatedButton(
              child: Text(
                controller.listQuestions.value?.length ==
                        (controller.numbQuestion.value + 1)
                    ? "Submit Quiz"
                    : "Next",
                style: AppStyles.black000Size16Fw600FfNunito,
              ),
              onPressed: () => controller.listQuestions.value?.length ==
                      (controller.numbQuestion.value + 1)
                  ? controller.finishQuestion()
                  : controller.nextQuestion(),
            ),
          ),
        ],
      ),
    );
  }
}

class AnswersWidget extends StatelessWidget {
  const AnswersWidget({
    super.key,
    required this.controller,
  });

  final HomeTabController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ItemAnswerWidget(
          controller: controller,
          color: appTheme.amberA700,
          answer: controller.listAnswers.value?[0] ?? "",
        ),
        SizedBox(
          height: getSize(32),
        ),
        ItemAnswerWidget(
          controller: controller,
          color: appTheme.red400.withOpacity(.5),
          answer: controller.listAnswers.value?[1] ?? "",
        ),
        SizedBox(
          height: getSize(32),
        ),
        ItemAnswerWidget(
          controller: controller,
          color: appTheme.blue500,
          answer: controller.listAnswers.value?[2] ?? "",
        ),
        SizedBox(
          height: getSize(32),
        ),
        ItemAnswerWidget(
          controller: controller,
          color: appTheme.deepOrange400Bf,
          answer: controller.listAnswers.value?[3] ?? "",
        ),
      ],
    );
  }
}

class ItemAnswerWidget extends StatelessWidget {
  const ItemAnswerWidget({
    super.key,
    required this.controller,
    required this.color,
    required this.answer,
  });

  final HomeTabController controller;
  final Color? color;
  final String? answer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.isCheckChoose.value
          ? () {}
          : controller.isCheckCorrectAnswer(answer ?? ""),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          answer ?? '',
          style: AppStyles.black000Size16Fw600FfNunito,
        ),
      ),
    );
  }
}

class AnswersTrueFalseWidget extends StatelessWidget {
  const AnswersTrueFalseWidget({
    super.key,
    required this.controller,
  });

  final HomeTabController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ItemAnswerWidget(
          controller: controller,
          color: appTheme.amberA700,
          answer: controller.listAnswers.value?[0] ?? "",
        ),
        SizedBox(
          height: getSize(32),
        ),
        ItemAnswerWidget(
          controller: controller,
          color: appTheme.blue500,
          answer: controller.listAnswers.value?[1] ?? "",
        ),
      ],
    );
  }
}