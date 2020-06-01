import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class CustomerScreen extends StatefulWidget {
  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> with TickerProviderStateMixin{
  static const platform = const MethodChannel('insync.flutter.dev/mrz');
  String filePath = "";
  String fullName = "";
  String idNumber = "";
  String expiryDate = "";
  String nationality = "";
  String imagepath = "";

  TextEditingController fullNameTextController;
  TextEditingController idNumberTextController;
  TextEditingController expiryDateTextController;
  TextEditingController nationalityTextController;
  Widget _uploadImageFileButton(String buttonText, Color color) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey[200],
            width: 2.0,
          )),
      child: Center(
        child: Text(
          buttonText.toUpperCase(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _uploadimage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Make a choice!'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Text('Gallery'),
                    onTap: () {
                      captureImage(context, ImageSource.gallery);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  GestureDetector(
                    child: Text('Camera'),
                    onTap: () {
                      // _openCamra(context);
                      captureImage(context, ImageSource.camera);
                    },
                  ),
                ],
              ),
            ),
          );
        });
    // var imagefile = await ImagePicker.pickImage(source: ImageSource.camera,maxWidth: 600);
  }

  Future<void> captureImage(
      BuildContext context, ImageSource imageSource) async {
    try {
      final imageFile = await ImagePicker.pickImage(source: imageSource);

      setState(() {
        imagepath=imageFile.path.toString();
      });
    } catch (e) {
      print(e);
    }
    Navigator.of(context).pop();
  }

  //void setState(Null Function() param0) {
  Future<void> _getMrzData() async {
    print('object');
    try {
      final Map<dynamic, dynamic> mrzData =
          await platform.invokeMethod('getMrzData');
      print('mrzdata $mrzData' "");
      print(mrzData['ImagePath'].toString());
      setState(() {
        filePath = mrzData['ImagePath'].toString();
        String firstName = mrzData['FirstName'].toString();
        String middleName = mrzData['MiddleName'].toString();
        String lastName = mrzData['LastName'].toString();

        if (firstName.isNotEmpty && middleName.isNotEmpty) {
          fullName = firstName + " " + middleName;
        } else if (lastName.isNotEmpty) {
          fullName = lastName;
        }

        if (mrzData['DocumentNumber'].toString().isNotEmpty) {
          idNumber = mrzData['DocumentNumber'].toString();
        }

        if (mrzData['DateOfExpiry'].toString().isNotEmpty) {
          expiryDate = mrzData['DateOfExpiry'].toString();
        }

        if (mrzData['Nationality'].toString().isNotEmpty) {
          nationality = mrzData['Nationality'].toString();
        }

        fullNameTextController.text = fullName;
        idNumberTextController.text = idNumber;
        expiryDateTextController.text = expiryDate;
        nationalityTextController.text = nationality;
      });
      //print(mrzData['ImagePath'].toString());
    } on PlatformException catch (e) {
      print("Failed to get mrz data : '${e.message}'");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customer Form')),
      body: ListView(
        //controller: scrollController,
        padding: EdgeInsets.only(
          top: AppBar().preferredSize.height +
              MediaQuery.of(context).padding.top +
              24,
          bottom: 62 + MediaQuery.of(context).padding.bottom,
        ),
        scrollDirection: Axis.vertical,
        children: <Widget>[
          Column(
            children: <Widget>[
              Material(
                elevation: 5.0,
                borderRadius: BorderRadius.all(
                  Radius.circular(15.0),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              '_packageName',
                              style: TextStyle(
                                color: Color(0xFF3E6BD0),
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '_packagePrice',
                              style: TextStyle(
                                color: Color(0xFF3E6BD0),
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                        controller: fullNameTextController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Full Name',
                        ),
                      ),
                      TextField(
                        controller: idNumberTextController,
                        decoration: InputDecoration(
                          suffixIcon: InkWell(
                            onTap: () {
                              _getMrzData();
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 10.0, 20.0, 10.0),
                              child: Icon(Icons.scanner),
                            ),
                          ),
                          border: OutlineInputBorder(),
                          labelText: 'ID Number',
                        ),
                      ),
                      imagepath.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  30.0, 10.0, 30.0, 10.0),
                              child: Image.file(
                                File(imagepath),
                                height: 100,
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 10.0, 20.0, 10.0),
                              child: SizedBox(
                                width: double.infinity,
                                height: 50.0,
                                child: Material(
                                  child: InkWell(
                                    onTap: () {
                                      _uploadimage(context);
                                    },
                                    child: _uploadImageFileButton(
                                        'Browse Image Files', Colors.white),
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(
                        height: 15.0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
