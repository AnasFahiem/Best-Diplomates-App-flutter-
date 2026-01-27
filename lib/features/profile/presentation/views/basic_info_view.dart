import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class BasicInfoView extends StatefulWidget {
  const BasicInfoView({super.key});

  @override
  State<BasicInfoView> createState() => _BasicInfoViewState();
}

class CountryData {
  final String name;
  final String code;
  final String flag;

  CountryData({required this.name, required this.code, required this.flag});
}

class _BasicInfoViewState extends State<BasicInfoView> {
  // State variables
  String? _selectedGender = 'Male';
  String? _selectedMaritalStatus = 'Single';
  late CountryData _selectedCountry;
  late CountryData _selectedEmergencyCountry;

  // Data Lists
  final List<String> _genders = ['Male', 'Female'];
  final List<String> _maritalStatuses = ['Single', 'Married', 'Divorced', 'Widowed'];
  
  final List<CountryData> _countries = [
    CountryData(name: "USA", code: "+1", flag: "🇺🇸"),
    CountryData(name: "Egypt", code: "+20", flag: "🇪🇬"),
    CountryData(name: "UK", code: "+44", flag: "🇬🇧"),
    CountryData(name: "India", code: "+91", flag: "🇮🇳"),
    CountryData(name: "Pakistan", code: "+92", flag: "🇵🇰"),
    CountryData(name: "UAE", code: "+971", flag: "🇦🇪"),
    CountryData(name: "Canada", code: "+1", flag: "🇨🇦"),
    CountryData(name: "Germany", code: "+49", flag: "🇩🇪"),
    CountryData(name: "France", code: "+33", flag: "🇫🇷"),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCountry = _countries[0]; // USA Default
    _selectedEmergencyCountry = _countries[0]; // USA Default
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Basic Information",
          style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.navyBlue,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      backgroundColor: AppColors.lightGrey,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.white,
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: AppColors.navyBlue,
                      child: Text("AF", style: TextStyle(fontSize: 30, color: AppColors.gold)),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: AppColors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField("First Name", "Anas"),
            _buildTextField("Last Name", "Fahiem"),
            _buildTextField("Email Address", "anas@example.com"),
            _buildTextField("Address", "123 Diplomat St, NY"),
            
            // Gender Dropdown
            _buildDropdownField(
              "Gender",
              _selectedGender,
              _genders,
              (val) => setState(() => _selectedGender = val),
            ),
            
            // Marital Status Dropdown
             _buildDropdownField(
              "Marital Status",
              _selectedMaritalStatus,
              _maritalStatuses,
              (val) => setState(() => _selectedMaritalStatus = val),
            ),

            _buildTextField("Nationality", "American"),
            
            // Phone Number with Rich Country Code
            _buildPhoneNumberField(
              "Phone Number",
              "234 567 890",
              _selectedCountry,
              (val) => setState(() => _selectedCountry = val!),
            ),
            
            _buildTextField("Emergency Contact Name", "Jane Doe"),
            
            // Emergency Contact with Rich Country Code
             _buildPhoneNumberField(
              "Emergency Contact Number",
              "987 654 321",
              _selectedEmergencyCountry,
              (val) => setState(() => _selectedEmergencyCountry = val!),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navyBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  "Save Changes",
                  style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String initialValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.grey),
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.gold),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.grey),
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.gold),
          ),
        ),
        dropdownColor: AppColors.white,
        icon: const Icon(Icons.arrow_drop_down, color: AppColors.navyBlue),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: GoogleFonts.poppins(color: AppColors.navyBlue),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPhoneNumberField(
    String label, 
    String initialValue, 
    CountryData currentCountry, 
    ValueChanged<CountryData?> onCountryChanged
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.grey),
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.gold),
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: AppColors.lightGrey)),
            ),
            width: 120, // Increased width for flag + code
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<CountryData>(
                  value: currentCountry,
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.navyBlue, size: 20),
                  dropdownColor: AppColors.white,
                  isExpanded: true,
                  selectedItemBuilder: (BuildContext context) {
                    return _countries.map<Widget>((CountryData country) {
                      return Row(
                        children: [
                          Text(country.flag, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            country.code,
                            style: GoogleFonts.poppins(color: AppColors.navyBlue, fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    }).toList();
                  },
                  items: _countries.map((CountryData country) {
                    return DropdownMenuItem<CountryData>(
                      value: country,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(country.flag, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              "${country.name} (${country.code})",
                              style: GoogleFonts.poppins(color: AppColors.navyBlue, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: onCountryChanged,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
