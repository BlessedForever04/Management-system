import 'package:flutter/material.dart';
import 'package:managementt/controller/member_controller.dart';
import 'package:managementt/model/member.dart';

class AddEmployee extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  // final TextEditingController positionController = TextEditingController();
  // final TextEditingController emailController = TextEditingController();
  // final TextEditingController phoneController = TextEditingController();
  final MemberController memberController = MemberController();

  AddEmployee({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Add Employee",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                  autocorrect: false,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  memberController.addMember(
                    Member(
                      name: nameController.text,
                      // position: positionController.text,
                      // email: emailController.text,
                      // phone: phoneController.text,
                      tasks: [],
                    ),
                  );
                },
                child: Text("Add Employee"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
