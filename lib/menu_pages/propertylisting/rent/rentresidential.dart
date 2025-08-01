import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:home_rental/menu_pages/propertylisting/buy/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:home_rental/consts.dart';
import 'package:home_rental/menu/homepage.dart';

class Rentresidential extends StatefulWidget {
  @override
  _RentresidentialState createState() => _RentresidentialState();
}

class _RentresidentialState extends State<Rentresidential> {
  final FirestoreService _firestoreService = FirestoreService();

  int singleRoomCount = 0;
  int doubleRoomCount = 0;
  int enSuiteDoubleRoomCount = 0;
  int bathroomsCount = 0;
  String? selectedAccess;
  String selectedPropertyType = 'House';
  String selectedLocation = 'Karachi';
  String selectedSize = '5 Marla';
  String selectedSellerType = 'Owner of the property';
  String selectedLease = '3 Months';
  String? selectedDate;

  List<String> propertyTypeList = [
    'House', 'Parking', 'Short Term', 'Apartment'
  ];

  List<String> propertySizeList = [
    '5 Marla', '10 Marla', '1 Kanal', '2 Kanal', '4 Kanal'
  ];

  List<String> sellerTypeList = [
    'Owner of the property',
    'Real Estate Developers & Builders',
    'Real Estate Investors (Flippers)',
    'Banks & Financial Institutions',
    'Government & Housing Authorities',
    'Commercial Property Owners & Corporations',
    'Landlords Selling Rental Properties',
    'Real Estate Agents (Acting as Sellers)',
  ];

  List<String> selectLocationList = [
    'Karachi', 'Lahore', 'Islamabad', 'Rawalpindi', 'Faisalabad',
    'Peshawar', 'Quetta', 'Multan', 'Gujranwala', 'Sialkot',
    'Hyderabad', 'Sargodha', 'Bahawalpur', 'Sukkur', 'Abbottabad',
    'Mardan', 'Gujrat', 'Rahim Yar Khan', 'Sheikhupura', 'Chiniot',
    'Dera Ghazi Khan', 'Kasur', 'Jhang', 'Sahiwal', 'Nawabshah',
    'Okara', 'Mirpur', 'Khuzdar', 'Kotli', 'Muzaffarabad',
    'Mingora', 'Skardu', 'Gilgit', 'Hunza', 'Chitral'
  ];

  List<String> selectLeaseList = [
    '3 Months',
    '6 Months',
    '9 Months',
    '1 Year',
    '2 Years',
    '3 Years',
  ];

  final _priceController = TextEditingController();
  final _cnicController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();

  List<String> uploadedImageName = []; // List of file paths
  List<String> base64Images = []; // To store base64 strings
  String? uploadedFileName;

  Future<void> convertImagesToBase64() async {
    base64Images.clear(); // Clear previous data

    for (var imagePath in uploadedImageName) {
      File imageFile = File(imagePath); // Convert path to File
      List<int> imageBytes = await imageFile.readAsBytes(); // Read file as bytes
      base64Images.add(base64Encode(imageBytes)); // Convert to Base64
    }

    print("Base64 Conversion Done: ${base64Images.length} images converted.");
  }


  bool isLoading = false; // Track loading state

  Future<void> _submitForm() async {
    if (uploadedImageName.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please upload at least 4 images.")),
      );
      return;
    }

    setState(() {
      isLoading = true; // Start loading
    });

    try {
      List<String> base64Images = [];
      for (var imagePath in uploadedImageName) {
        File imageFile = File(imagePath); // Convert path to File
        List<int> imageBytes = await imageFile.readAsBytes();
        base64Images.add(base64Encode(imageBytes)); // Convert to Base64
      }

      await _firestoreService.Rentresidential(
        propertyType: selectedPropertyType,
        singleRooms: singleRoomCount,
        doubleRooms: doubleRoomCount,
        enSuiteRooms: enSuiteDoubleRoomCount,
        bathrooms: bathroomsCount,
        price: double.parse(_priceController.text),
        cnic: _cnicController.text,
        propertySize: selectedSize,
        sellerType: selectedSellerType,
        location: selectedLocation,
        lease: selectedLease,
        startDate: _dateController.text,
        access: selectedAccess,
        description: _descriptionController.text,
        gas: amenities[0].isSelected,
        elecricity: amenities[1].isSelected,
        watersupply: amenities[2].isSelected,
        cable: amenities[3].isSelected,
        wifi: amenities[4].isSelected,
        greatlocation: amenities[5].isSelected,
        images: base64Images,
      );

      // Navigate to HomePage after successful submission
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving property: $e")),
      );
    }

    setState(() {
      isLoading = false; // Stop loading
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        backgroundColor: Colors.red.shade300,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text(
                  'Property type',
                  style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium!.color),
                ),
                SizedBox(height: 5),
                DropdownButtonFormField(
                  value: selectedPropertyType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  isExpanded: true,
                  hint: Text('Select'),
                  items: propertyTypeList.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option, style: TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (String? v){
                    selectedPropertyType = v!;
                    setState(() {});
                  },
                ),
                SizedBox(height: 20),

                // Room counters
                _buildCounterRow('Single room', singleRoomCount, (value) {
                  setState(() {
                    singleRoomCount = value;
                  });
                }),
                _buildCounterRow('Double room', doubleRoomCount, (value) {
                  setState(() {
                    doubleRoomCount = value;
                  });
                }),
                _buildCounterRow('En Suite Double room', enSuiteDoubleRoomCount, (value) {
                  setState(() {
                    enSuiteDoubleRoomCount = value;
                  });
                }),
                _buildCounterRow('Bathrooms', bathroomsCount, (value) {
                  setState(() {
                    bathroomsCount = value;
                  });
                }),
                SizedBox(height: 20),

                // Access buttons
                Text(
                  'Access',
                  style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium!.color),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedAccess = 'Business Hours';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: selectedAccess == 'Business Hours' ? Colors.red.shade300 : Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Business Hours',
                          style: TextStyle(
                            color: selectedAccess == 'Business Hours' ? Colors.white : Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedAccess = '24/7 Available';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: selectedAccess == '24/7 Available' ? Colors.red.shade300 : Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '24/7 Available',
                          style: TextStyle(
                            color: selectedAccess == '24/7 Available' ? Colors.white : Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),



                _buildTextField('Price', 'Enter price in PKR',_priceController, type: "price"),
                SizedBox(height: 20),

                _buildTextField('CNIC', 'Enter CNIC (e.g., 12345-1234567-1)',_cnicController, type: "cnic"),
                SizedBox(height: 20),
                Text(
                  'Property Size',
                  style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium!.color),
                ),
                SizedBox(height: 5),
                DropdownButtonFormField(
                  value: selectedSize,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  isExpanded: true,
                  hint: Text('Select property size'),
                  items: propertySizeList.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option, style: TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (String? v){
                    selectedSize = v!;
                    setState(() {});
                  },
                ),
                SizedBox(height: 20),

                Text(
                  'Seller Type',
                  style: TextStyle(fontSize: 14,color: Theme.of(context).textTheme.bodyMedium!.color),
                ),
                SizedBox(height: 5),
                DropdownButtonFormField(
                  value: selectedSellerType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  isExpanded: true,
                  hint: Text('Select Seller Type'),
                  items: sellerTypeList.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option, style: TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (String? v) {
                    selectedSellerType = v!;
                    setState(() {}); // ✅ Update state when seller type changes
                  },
                ),
                SizedBox(height: 20),


                Text(
                  'Select Minimum Lease',
                  style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium!.color),
                ),
                SizedBox(height: 5),
                DropdownButtonFormField(
                  value: selectedLease,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  isExpanded: true,
                  hint: Text('Select Minimum Lease'),
                  items: selectLeaseList.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option, style: TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (String? v){
                    selectedLease = v!;
                    setState(() {});
                  },
                ),
                SizedBox(height: 20),

                SizedBox(height: 1),
                _buildDatePicker('Lease Start Date', 'Select start date', _dateController),

                SizedBox(height: 20),
                Text(
                  'Select Location',
                  style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium!.color),
                ),
                SizedBox(height: 5),
                DropdownButtonFormField(
                  value: selectedLocation,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  isExpanded: true,
                  hint: Text('Select Location'),
                  items: selectLocationList.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option, style: TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (String? v){
                    selectedLocation = v!;
                    setState(() {});
                  },
                ),
                SizedBox(height: 20),
                _buildTextField('Description', 'Enter property description',_descriptionController),
                SizedBox(height: 20),

                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 3, // Width/height ratio
                  ),
                  itemCount: amenities.length,
                  itemBuilder: (context, index) {
                    final amenity = amenities[index];
                    return Card(
                      elevation: 2,
                      child: ListTileTheme(
                        horizontalTitleGap: 0.0,
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(amenity.name),
                          value: amenity.isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              amenity.isSelected = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 10),

                // _buildUploadSection('Upload Brochure (Optional)', _pickFile, uploadedFileName),
                // SizedBox(height: 10),

                _buildUploadSection2('Upload Image (Minimum 4)', _pickImage, uploadedImageName),
                SizedBox(height: 100),
              ],
            ),
          ),

          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submitForm, // Disable button when loading
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade300,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
                  : Text(
                'Submit',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),

        ],
      ),
    );
  }



  Widget _buildTextField(
      String label,
      String hint,
      TextEditingController controller,
      {String? type} // ✅ Added type parameter for CNIC & Price validation
      ) {
    String? errorText; // For validation errors

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium!.color)),
            SizedBox(height: 5),
            TextField(
              controller: controller,
              keyboardType: type == "cnic"
                  ? TextInputType.number
                  : (type == "price" ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text),

              // ✅ Input formatters based on type
              inputFormatters: type == "cnic"
                  ? [
                FilteringTextInputFormatter.digitsOnly, // ✅ Only numbers for CNIC
                LengthLimitingTextInputFormatter(13), // ✅ Max 13 digits for CNIC
              ]
                  : (type == "price"
                  ? [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')), // ✅ Only digits & one decimal
              ]
                  : []),

              onChanged: (value) {
                setState(() {
                  if (type == "cnic") { // ✅ CNIC Validation
                    if (value.isEmpty) {
                      errorText = 'CNIC is required.';
                    } else if (value.length < 13) {
                      errorText = 'CNIC must be 13 digits long.';
                    } else {
                      errorText = null; // ✅ Clear error if valid
                    }
                  } else if (type == "price") { // ✅ Price Validation
                    if (value.isEmpty) {
                      errorText = 'Price is required.';
                    } else if (!RegExp(r'^\d*\.?\d{0,2}$').hasMatch(value)) {
                      errorText = 'Enter a valid price (e.g., 123.45).';
                    } else {
                      errorText = null; // ✅ Clear error if valid
                    }
                  }
                });
              },

              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(),
                errorText: errorText, // ✅ Show error for CNIC or Price
              ),
            ),
          ],
        );
      },
    );
  }

  /*Widget _buildUploadSection(String title, Function() onTap, String? fileName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium!.color),
        ),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    fileName ?? 'Click to upload',
                    style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium!.color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            fileName == null
                ? ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(Icons.upload_file, color: Colors.white, size: 18),
              label: Text('Upload', style: TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade300,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
                : ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  uploadedFileName = null;
                });
              },
              icon: Icon(Icons.close, color: Colors.white, size: 18),
              label: Text('Remove', style: TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade300,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }*/

  Widget _buildUploadSection2(String title, Function() onTap, List<String> fileName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium!.color),
        ),
        Row(
          children: [
            fileName.isEmpty
                ? Expanded(
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Click to upload',
                    style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium!.color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            )
                : Expanded(
              child: SizedBox(
                height: 60,
                child: ListView.builder(
                  itemCount: fileName.length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(5),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(File(fileName[index]), fit: BoxFit.cover),
                            Positioned(
                              top: 1,
                              right: 1,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    fileName.removeAt(index);
                                  });
                                },
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.black,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(Icons.upload_file, color: Colors.white, size: 18),
              label: Text(fileName.isEmpty ? 'Upload' : 'Add More', style: TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade300,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Method to build counter rows
  Widget _buildCounterRow(String label, int value, ValueChanged<int> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium!.color),
        ),
        Row(
          children: [
            IconButton(
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
              icon: Icon(Icons.remove_circle_outline, color: Colors.grey.shade400),
            ),
            Text(value.toString(), style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium!.color)),
            IconButton(
              onPressed: () => onChanged(value + 1),
              icon: Icon(Icons.add_circle_outline, color: Colors.red.shade300),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, String hint, TextEditingController dateController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium!.color),
        ),
        SizedBox(height: 5),
        GestureDetector(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );

            if (pickedDate != null) {
              String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
              dateController.text = formattedDate; // Update the text controller with the selected date
              setState(() {}); // Call setState to refresh the UI with the new date
            }
          },
          child: Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateController.text.isEmpty ? hint : dateController.text,
                  style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium!.color),
                ),
                Icon(Icons.calendar_today, color: Theme.of(context).textTheme.bodyMedium!.color, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Future<void> _pickFile() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx']);
  //   if (result != null) setState(() => uploadedFileName = result.files.single.name);
  // }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,  // ✅ Allow multiple image selection
    );

    if (result != null) {
      setState(() {
        uploadedImageName.addAll(result.files.map((file) => file.path!).toList()); // ✅ Naye images purani images ke saath add hongi
      });
    }
  }
}
