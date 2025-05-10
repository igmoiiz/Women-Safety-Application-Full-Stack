class CustomMenuContainerModel {
  final String title;
  final String image;
  final String route;

  CustomMenuContainerModel(
      {required this.title, required this.image, required this.route});
}

List<CustomMenuContainerModel> customMenuContainerlist = [
  CustomMenuContainerModel(
      title: 'Pink Area',
      image: 'assets/images/homeDoor.png',
      route: '/bottomNavigation/home/PinkArea'),
  CustomMenuContainerModel(
      title: 'Red Area',
      image: 'assets/images/menu_redArea.png',
      route: '/bottomNavigation/home/RedArea'),
  CustomMenuContainerModel(
      title: 'Laws',
      image: 'assets/images/menu_laws.png',
      route: '/bottomNavigation/home/MenuSreen/LawScreen'),
  CustomMenuContainerModel(
      title: 'Locate',
      image: 'assets/images/homeLocation.png',
      route: '/bottomNavigation/home/locateScreen'),
  CustomMenuContainerModel(
      title: 'Emergency',
      image: 'assets/images/menu_emergency.png',
      route: '/bottomNavigation/home/MenuSreen/EmegencyScreen'),
];
