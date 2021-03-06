import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:recipes_app_flutter/recipes/model/Recipe.dart';
import 'package:recipes_app_flutter/recipes/model/ResAddRecipe.dart';
import 'package:recipes_app_flutter/res/Fonts.dart' as Fonts;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class AddRecipeScreen extends StatefulWidget {
  final Recipe recipe;

  AddRecipeScreen({Key key, @required this.recipe}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final nameController = TextEditingController();
  final servesController = TextEditingController();
  final linkController = TextEditingController();
  final prepareTimeController = TextEditingController();
  final tagController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String dropdownValue = '';
  List<String> _dynamicChips = [];
  File imageFile;
  var isSubmiting = false;

  @override
  void initState() {
    super.initState();
    /* nameController..text = widget.recipe != null ? widget.recipe.name : '';
    servesController..text = widget.recipe != null ? widget.recipe.serves : '';
    linkController..text = widget.recipe != null ? widget.recipe.ytUrl : '';
    prepareTimeController
      ..text = widget.recipe != null ? widget.recipe.preparationTime : '';
    dropdownValue = widget.recipe != null ? widget.recipe.complexity : '';
    _setMetaTags(); */
  }

  @override
  void dispose() {
    super.dispose();
    tagController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Recipe'),
      ),
      body: new SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(children: <Widget>[
                GestureDetector(
                  child: Container(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _decideImageView(),
                    ),
                  ),
                  onTap: () {
                    _showPickerDialog(context);
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Name required!';
                    }
                    return null;
                  },
                  controller: nameController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Name'),
                ),
                SizedBox(height: 20),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Serves required!';
                    }
                    return null;
                  },
                  controller: servesController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Serves'),
                ),
                SizedBox(height: 20),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Url required!';
                    }
                    return null;
                  },
                  controller: linkController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: 'You Tube Link'),
                ),
                SizedBox(height: 20),
                TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Time required!';
                    }
                    return null;
                  },
                  controller: prepareTimeController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Preparation Time'),
                ),
                SizedBox(height: 20),
                DropdownButton<String>(
                  isExpanded: true,
                  value: dropdownValue.isEmpty ? null : dropdownValue,
                  hint: Text(
                    'Complexity',
                    style: TextStyle(
                        fontSize: 16, fontFamily: Fonts.Metropolis_Regular),
                  ),
                  style: TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Theme.of(context).accentColor,
                  ),
                  items: <String>['Easy', 'Medium', 'Difficult']
                      .map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      dropdownValue = newValue;
                    });
                  },
                ),
                SizedBox(height: 20),
                Chip(
                  label: Container(
                    child: TextField(
                      decoration: new InputDecoration.collapsed(
                          hintText: 'Add Categories'),
                      controller: tagController,
                      onSubmitted: (value) {
                        setState(() {
                          tagController.clear();
                          _dynamicChips.add(value);
                        });
                      },
                    ),
                  ),
                  onDeleted: () {},
                  deleteIcon: Icon(Icons.add),
                ),
                SizedBox(height: 10),
                dynamicChips(),
                SizedBox(height: 40),
                getSubmitOrProgress(),
              ]),
            )),
      ),
    );
  }

  _openGallery(BuildContext context) async {
    var imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.imageFile = imageFile;
    });
    Navigator.of(context).pop();
  }

  _openCamera(BuildContext context) async {
    var imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      this.imageFile = imageFile;
    });
    Navigator.of(context).pop();
  }

  Widget _decideImageView() {
    if (imageFile != null) {
      return Image.file(
        imageFile,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        'assets/images/recipe_place_holder.jpg',
        fit: BoxFit.cover,
      );
    }
  }

  Future<void> _showPickerDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Take a action!'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Text('Gallery'),
                    onTap: () {
                      _openGallery(context);
                    },
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  GestureDetector(
                    child: Text('Camera'),
                    onTap: () {
                      _openCamera(context);
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  dynamicChips() {
    return Wrap(
      spacing: 6.0,
      runSpacing: 6.0,
      children: List<Widget>.generate(_dynamicChips.length, (int index) {
        return Chip(
          label: Text(_dynamicChips[index]),
          onDeleted: () {
            setState(() {
              _dynamicChips.removeAt(index);
            });
          },
          deleteIcon: Icon(Icons.delete),
        );
      }),
    );
  }

  Future<ResAddRecipe> addRecipe() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    String url = 'http://35.160.197.175:3006/api/v1/recipe/add';
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Authorization": token
    };
    Map data = {
      'name': nameController.text,
      'preparationTime': prepareTimeController.text,
      'serves': int.parse(servesController.text),
      'complexity': dropdownValue,
      'ytUrl': linkController.text,
      'metaTags': _dynamicChips
    };
    final response =
        await http.post(url, headers: headers, body: json.encode(data));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return ResAddRecipe.fromJson(json.decode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  addUpdateRecipePhoto(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    var dio = Dio();
    String fileName = imageFile.path.split('/').last;
    FormData formData = FormData.fromMap({
      "recipeId": id.toString(),
      "photo": await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: new MediaType("image", "jpeg"),
      ),
    });

    var response = await dio.post(
      "http://35.160.197.175:3006/api/v1/recipe/add-update-recipe-photo",
      data: formData,
      options: Options(
        headers: {"Authorization": token},
      ),
      onSendProgress: (int sent, int total) {
        debugPrint("sent${(sent / total * 100) / 100}");
        setState(() {
          // _progressValue = sent / total * 100;
        });
      },
    ).whenComplete(() {
      setState(() {
        imageFile = imageFile;
        isSubmiting = false;
        Navigator.of(context).pop();
      });
    }).catchError((onError) {
      debugPrint("error:${onError.toString()}");
    });

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      // return ResUploadPhoto.fromJson(json.decode(response.body));
      debugPrint("complete:${response.data.toString()}");
      Fluttertoast.showToast(
        msg: "Uploaded!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      debugPrint("Response upload photo: $response");
      throw Exception('Failed to load album');
    }
  }

  Widget getSubmitOrProgress() {
    if (!isSubmiting) {
      return FlatButton(
        color: Theme.of(context).accentColor,
        textColor: Colors.white,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        padding: const EdgeInsets.fromLTRB(40.0, 16.0, 40.0, 16.0),
        splashColor: Colors.redAccent,
        onPressed: () {
          if (_formKey.currentState.validate()) {
            isSubmiting = true;
            addRecipe().then((resAddRecipe) {
              debugPrint("resAddRecipe:" + resAddRecipe.toString());
              if (imageFile != null) {
                addUpdateRecipePhoto(resAddRecipe.id);
              } else {
                isSubmiting = false;
                Navigator.of(context).pop();
              }
            });
          }
        },
        child: Text("Submit", style: TextStyle(fontSize: 14.0)),
      );
    } else {
      return CircularProgressIndicator(
        backgroundColor: Colors.white,
        valueColor:
            AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
      );
    }
  }
}
