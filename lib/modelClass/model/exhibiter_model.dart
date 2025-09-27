class Exhibiter {
  final String name;
  final String Imageurl;
  final String badge;
  final String catogory;

  final String? email;
  final String? organization;
  final String? website;
  final String? location;
  final String? about;
  final String? country;

  Exhibiter({
    required this.name,
    required this.Imageurl,
    required this.badge,
    required this.catogory,
    this.email,
    this.organization,
    this.website,
    this.location,
    this.about,
    this.country,
  });
}
