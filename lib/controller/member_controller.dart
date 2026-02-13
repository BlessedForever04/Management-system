import 'package:get/get.dart';
import 'package:managementt/model/member.dart';
import 'package:managementt/service/member_service.dart';

class MemberController extends GetxController{

  final MemberService _memberService = MemberService();
  var members = <Member>[].obs;

  @override
  void onInit(){
    getMembers();
    super.onInit();
  }

  void addMember(Member member)  async{
   await _memberService.addMember(member);
   getMembers();
  }


  void getMembers() async{
     members.value = await _memberService.getMembers();
  }

  void removeMember(String id) async {
   await _memberService.removeMember(id);
    getMembers();
  }
}