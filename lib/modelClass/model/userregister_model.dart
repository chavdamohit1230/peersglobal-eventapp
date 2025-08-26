class userRegister{

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
    final String?  businessLocation;
    final String? companywebsite;
    final String? industry;
    final String? purposeOfAttending;
    final String? hearAboutUs;
    final String? otherInfo;

    userRegister({

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

    Map<String,dynamic> tojson(){
        return{

          "fields":{
            "name":{"Stringvalue":name},
            "email":{"Stringvalue":email},
            "mobile":{""}

          }

        };
    }

}