import 'package:flutter/material.dart';

class AlertsPage extends StatefulWidget {
  @override
  _AlertsPageState createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  // State for toggles
  bool notifyShareRoom = false;
  bool notifyRentResidential = false;
  bool notifyCommercialToLet = false;
  bool notifyResidential = false;
  bool notifyCommercial = false; // Added Commercial toggle

  // List of counties (example)
  List<String> counties = ['All in Pakistan', 'Karachi', 'Lahore', 'Islamabad', 'Rawalpindi', 'Faisalabad',
    'Peshawar', 'Quetta', 'Multan', 'Gujranwala', 'Sialkot',
    'Hyderabad', 'Sargodha', 'Bahawalpur', 'Sukkur', 'Abbottabad',
    'Mardan', 'Gujrat', 'Rahim Yar Khan', 'Sheikhupura', 'Chiniot',
    'Dera Ghazi Khan', 'Kasur', 'Jhang', 'Sahiwal', 'Nawabshah',
    'Okara', 'Mirpur', 'Khuzdar', 'Kotli', 'Muzaffarabad',
    'Mingora', 'Skardu', 'Gilgit', 'Hunza', 'Chitral'];

  // Selected counties
  String selectedShareRoomCounty = 'All in Pakistan';
  String selectedRentResidentialCounty = 'All in Pakistan';
  String selectedCommercialToLetCounty = 'All in Pakistan';
  String selectedResidentialCounty = 'All in Pakistan';
  String selectedCommercialCounty = 'All in Pakistan'; // Added Commercial county

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alerts'),
        backgroundColor: Colors.red.shade300,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeaderRow('Property type', 'Notify me'),
          SizedBox(height: 20),
          _buildAlertSection(
            'Share (Rent a room)',
            notifyShareRoom,
                (value) {
              setState(() {
                notifyShareRoom = value;
              });
            },
            selectedShareRoomCounty,
                (String? newValue) {
              setState(() {
                selectedShareRoomCounty = newValue!;
              });
            },
          ),
          _buildAlertSection(
            'Rent Residential',
            notifyRentResidential,
                (value) {
              setState(() {
                notifyRentResidential = value;
              });
            },
            selectedRentResidentialCounty,
                (String? newValue) {
              setState(() {
                selectedRentResidentialCounty = newValue!;
              });
            },
          ),
          _buildAlertSection(
            'Commercial (To Let)',
            notifyCommercialToLet,
                (value) {
              setState(() {
                notifyCommercialToLet = value;
              });
            },
            selectedCommercialToLetCounty,
                (String? newValue) {
              setState(() {
                selectedCommercialToLetCounty = newValue!;
              });
            },
          ),
          _buildAlertSection(
            'Residential',
            notifyResidential,
                (value) {
              setState(() {
                notifyResidential = value;
              });
            },
            selectedResidentialCounty,
                (String? newValue) {
              setState(() {
                selectedResidentialCounty = newValue!;
              });
            },
          ),
          _buildAlertSection(
            'Commercial', // Added new section for Commercial
            notifyCommercial,
                (value) {
              setState(() {
                notifyCommercial = value;
              });
            },
            selectedCommercialCounty,
                (String? newValue) {
              setState(() {
                selectedCommercialCounty = newValue!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(String title, String toggleText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14), // Reduced font size, removed bold
        ),
        Text(
          toggleText,
          style: TextStyle(fontSize: 14), // Reduced font size, removed bold
        ),
      ],
    );
  }

  Widget _buildAlertSection(String title, bool toggleValue, Function(bool) onToggleChanged,
      String selectedCounty, ValueChanged<String?> onCountyChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14), // Reduced font size, removed bold
            ),
            _buildCustomSwitch(toggleValue, onToggleChanged), // Updated to custom button
          ],
        ),
        SizedBox(height: 5),
        Text(
          'Preferred county',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700), // Adjusted font size
        ),
        SizedBox(height: 5),
        Container(
          height: 45,
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: selectedCounty,
            isExpanded: true,
            underline: SizedBox(),
            onChanged: onCountyChanged,
            items: counties.map((String county) {
              return DropdownMenuItem(
                value: county,
                child: Text(county, style: TextStyle(fontSize: 14)),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  // Custom Switch Button with red shade when toggled on
  Widget _buildCustomSwitch(bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: 22, // Compact height
        width: 40, // Compact width
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value ? Colors.red.shade300 : Colors.grey.shade400, // Red shade when on
        ),
        child: Stack(
          children: [
            Align(
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(3.0), // Compact padding
                child: Container(
                  height: 16, // Compact toggle button
                  width: 16, // Compact toggle button
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
