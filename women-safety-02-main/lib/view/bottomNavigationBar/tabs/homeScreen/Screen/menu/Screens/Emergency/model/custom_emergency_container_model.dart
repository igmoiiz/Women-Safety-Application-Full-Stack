class CustomEmergencyContainerModel {
  String title;
  String image;
  String phoneNumber;
  CustomEmergencyContainerModel(
      {required this.title, required this.image, required this.phoneNumber});
}

List<CustomEmergencyContainerModel> customEmergencyContainerModel = [
  CustomEmergencyContainerModel(
    title: 'Police',
    image: 'assets/images/pubjab_police.png',
    phoneNumber: '15',
  ),
  CustomEmergencyContainerModel(
    title: 'Rescue 1122',
    image: 'assets/images/Rescue1122.png',
    phoneNumber: '1122',
  ),
  CustomEmergencyContainerModel(
    title: 'Ministry of Human Rights',
    image: 'assets/images/ministry_human.png',
    phoneNumber: '1099',
  ),
  CustomEmergencyContainerModel(
    title: 'FIA',
    image: 'assets/images/fia.jpg',
    phoneNumber: '111-345-786',
  ),
  CustomEmergencyContainerModel(
    title: 'Cyber Crime Wing (FIA)',
    image: 'assets/images/cyber_crime_wing.png',
    phoneNumber: '1991',
  ),
  CustomEmergencyContainerModel(
    title: 'Virtual Police Station Women',
    image: 'assets/images/Virtual_Police_Station_Women.png',
    phoneNumber: '15',
  ),
];
