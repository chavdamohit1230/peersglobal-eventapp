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
            "mobile":{"Strigvalue":mobile},
            "countrycode":{"Stringvalue":countrycode},
            "country":{"Stringvalue":country},
            "state":{"Stringvalue":state},
            "city":{"Strignvalue":city},
            "aboutme":{"Stringvalue":aboutme},
            "organization":{"Stringvalue":organization},
            "designation":{"Stringvalue":designation},
            "businessLocation":{"Stringvalue":businessLocation},
            "companywebsite":{"Stringvalue":companywebsite},
            "industry":{"Stringvalue":industry},
            "purposeOfAttending":{"Stringvalue":purposeOfAttending},
            "hearAboutUs":{"Stringvalue":hearAboutUs},
            "otherInfo":{"Stringvalue":otherInfo}

          }

        };
    }

}