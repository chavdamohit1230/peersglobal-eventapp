class UserRegister {
  final String? name;
  final String? email;
  final String? mobile;
  final String? countrycode;
  final String? country;
  final String? state;
  final String? city;
  final String? aboutme;
  final String? organization;
  final String? designation;
  final String? businessLocation;
  final String? companywebsite;
  final String? industry;
  final String? purposeOfAttending;
  final String? hearAboutUs;
  final String? otherInfo;

  UserRegister({
    this.name,
    this.email,
    this.mobile,
    this.countrycode,
    this.country,
    this.state,
    this.city,
    this.aboutme,
    this.organization,
    this.designation,
    this.businessLocation,
    this.companywebsite,
    this.industry,
    this.purposeOfAttending,
    this.hearAboutUs,
    this.otherInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      "fields": {
        "name": {"stringValue": name ?? ""},
        "email": {"stringValue": email ?? ""},
        "mobile": {"stringValue": mobile ?? ""},
        "countrycode": {"stringValue": countrycode ?? ""},
        "country": {"stringValue": country ?? ""},
        "state": {"stringValue": state ?? ""},
        "city": {"stringValue": city ?? ""},
        "aboutme": {"stringValue": aboutme ?? ""},
        "organization": {"stringValue": organization ?? ""},
        "designation": {"stringValue": designation ?? ""},
        "businessLocation": {"stringValue": businessLocation ?? ""},
        "companywebsite": {"stringValue": companywebsite ?? ""},
        "industry": {"stringValue": industry ?? ""},
        "purposeOfAttending": {"stringValue": purposeOfAttending ?? ""},
        "hearAboutUs": {"stringValue": hearAboutUs ?? ""},
        "otherInfo": {"stringValue": otherInfo ?? ""}
      }
    };
  }
}
