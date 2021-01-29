import 'package:kryptokafe/utils/assets.dart';

class UsStates {
  final String stateName;
  final String stateCode;

  UsStates({this.stateCode, this.stateName});

  getStateList() {
    List<UsStates> usStateList = [];
    Assets().usStates.forEach((key, value) {
      usStateList.add(UsStates(stateCode: key, stateName: value));
    });
    return usStateList;
  }
}
