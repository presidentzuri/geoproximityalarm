class Address{
  late String placename;
  late double latitude;
  late double longitude;
  late String placeId;
  late String placeformattedAddress;



  Address({
    required this.placeId,
    required this.latitude,
    required this.longitude,
    required this.placename,
    required this.placeformattedAddress,

  });
  String getplaceId(){
    return placeId;
  }
  String getplaceformattedAddress(){
    return placeformattedAddress;
  }

}