import 'package:flutter/material.dart';

class SchedulingLink extends StatefulWidget {
  @override
  _SchedulingLinkState createState() => _SchedulingLinkState();
}

class _SchedulingLinkState extends State<SchedulingLink> {
  String? _selectedPurpose;
  final TextEditingController _meetingTitleController = TextEditingController();
  final TextEditingController _meetingAddressController = TextEditingController();
  DateTime? _selectedStartDate;
  String _selectedInterval = "30 minutes";

  // Validation flags
  bool _titleError = false;
  bool _addressError = false;

  Map<String, bool> _selectedDays = {
    "MON": false,
    "TUE": false,
    "WED": false,
    "THU": false,
    "FRI": false,
    "SAT": false,
    "SUN": false,
  };

  Map<String, String> _startTime = {
    "MON": "07:00",
    "TUE": "07:00",
    "WED": "07:00",
    "THU": "07:00",
    "FRI": "07:00",
    "SAT": "07:00",
    "SUN": "07:00",
  };

  Map<String, String> _endTime = {
    "MON": "21:00",
    "TUE": "21:00",
    "WED": "21:00",
    "THU": "21:00",
    "FRI": "21:00",
    "SAT": "21:00",
    "SUN": "21:00",
  };

  final List<String> _intervalOptions = [
    "10 minutes",
    "20 minutes",
    "30 minutes",
    "1 hour",
    "2 hours"
  ];

  bool _areFieldsValid() {
    return _selectedPurpose != null &&
        _meetingTitleController.text.isNotEmpty &&
        _meetingAddressController.text.isNotEmpty &&
        _selectedStartDate != null;
  }

  void _generateURL() {
    if (_areFieldsValid()) {
      String url =
          "https://example.com/schedule?purpose=$_selectedPurpose&title=${_meetingTitleController.text}&address=${_meetingAddressController.text}&startDate=${_selectedStartDate!.toIso8601String()}&interval=$_selectedInterval";

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Generated URL"),
          content: SelectableText(url),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        ),
      );
    }
  }

  void _validateFields() {
    setState(() {
      _titleError = _meetingTitleController.text.isEmpty;
      _addressError = _meetingAddressController.text.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scheduling'),
        backgroundColor: Colors.red.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildStepTitle(1, 'Select Meeting Purpose', 'What will you use this meeting for?'),
            SizedBox(height: 10),
            _buildOptionTile('Property Viewing', 'property_viewing'),
            SizedBox(height: 10),
            _buildOptionTile('Personal Meeting', 'personal_meeting'),
            SizedBox(height: 20),

            _buildStepTitle(2, 'Select a property', 'Select the properties you want to set viewing dates on'),
            SizedBox(height: 10),
            _buildTextField(
              'Meeting Title',
              'Example: 30-minute f2f chat, Coffee with me',
              _meetingTitleController,
              error: _titleError,
            ),
            SizedBox(height: 15),
            _buildTextField(
              'Meeting Address',
              'e.g. 22 Hollywoodrath Road, Hollystown, Dublin 15',
              _meetingAddressController,
              error: _addressError,
            ),
            SizedBox(height: 20),

            _buildStepTitle(3, 'Set Property Viewing Availability', 'Select the dates this property is available for viewing'),
            SizedBox(height: 10),
            Text(
              'Select Days of the Week',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            SizedBox(height: 10),
            ..._selectedDays.keys.map((day) {
              return _buildDayAvailability(day);
            }).toList(),

            SizedBox(height: 20),

            _buildDropdownField('Intervals', _selectedInterval, _intervalOptions, (String? newValue) {
              setState(() {
                _selectedInterval = newValue!;
              });
            }),
            SizedBox(height: 15),

            _buildDateField(
              'Start Date',
              _selectedStartDate != null
                  ? '${_selectedStartDate!.day}-${_selectedStartDate!.month}-${_selectedStartDate!.year}'
                  : 'Select start date',
                  () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedStartDate = pickedDate;
                  });
                }
              },
            ),
            SizedBox(height: 30),

            ElevatedButton(
              onPressed: _areFieldsValid() ? _generateURL : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _areFieldsValid() ? Colors.red.shade300 : Colors.grey.shade400,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Generate URL',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTitle(int stepNumber, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: Colors.grey.shade300,
              child: Text(
                stepNumber.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal, // Normal font weight
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile(String title, String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPurpose = value;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedPurpose == value ? Colors.red.shade300 : Colors.grey.shade400,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(fontSize: 16),
          ),
          trailing: Icon(
            Icons.circle,
            color: _selectedPurpose == value ? Colors.red.shade300 : Colors.transparent,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hintText, TextEditingController controller, {bool error = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          onChanged: (value) => _validateFields(),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: error ? Colors.red : Colors.grey.shade400,
              ),
            ),
            errorText: error ? 'This field is required' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDayAvailability(String day) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Checkbox(
            value: _selectedDays[day],
            activeColor: Colors.pink,
            onChanged: (bool? value) {
              setState(() {
                _selectedDays[day] = value ?? false;
              });
            },
          ),
          Text(
            day,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          ),
          Spacer(),
          if (_selectedDays[day] == true) ...[
            _buildTimeDropdown(day, true),
            Text(' - ', style: TextStyle(fontSize: 16)),
            _buildTimeDropdown(day, false),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeDropdown(String day, bool isStartTime) {
    return SizedBox(
      width: 80,
      child: DropdownButton<String>(
        value: isStartTime ? _startTime[day] : _endTime[day],
        underline: SizedBox(),
        onChanged: (String? newValue) {
          setState(() {
            if (isStartTime) {
              _startTime[day] = newValue!;
            } else {
              _endTime[day] = newValue!;
            }
          });
        },
        items: [
          for (var hour = 7; hour <= 21; hour++)
            DropdownMenuItem(
              value: '${hour.toString().padLeft(2, '0')}:00',
              child: Text('${hour.toString().padLeft(2, '0')}:00'),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
        SizedBox(height: 5),
        Container(
          height: 35,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: SizedBox(),
            onChanged: onChanged,
            items: options.map((String option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option, style: TextStyle(fontSize: 14)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, String hintText, Function() onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
        SizedBox(height: 5),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 35,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hintText,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
