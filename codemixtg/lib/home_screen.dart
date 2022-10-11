import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _source = TextEditingController();
  final _target = TextEditingController();
  final _output = TextEditingController();
  bool _isLoading = false;

  _validate() async {
    _output.text = "";
    setState(() {});

    String source = _source.text.split(".")[0];
    String target = _target.text.split(".")[0];

    if (source.isNotEmpty && target.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      await _hitApi(source, target);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields."),
        ),
      );
    }
  }

  _hitApi(source, target) async {
    Map<String, String> body = {
      "src": source,
      "target": target,
    };

    var url = Uri.parse("http://192.168.0.101:3000/generate");

    var response = await http.post(url, body: jsonEncode(body));

    var res = jsonDecode(response.body);

    if (response.statusCode == 201) {
      _output.text = "";
      _output.text = res["output"];
      _isLoading = false;
      setState(() {});
    } else {
      _source.text = "";
      _target.text = "";
      _output.text = "";
      _isLoading = false;

      setState(() {});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error ${res["message"]}"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  margin:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).backgroundColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 700.0,
                        height: 110.0,
                        child: Shimmer.fromColors(
                          baseColor: const Color(0xFFfc00ff),
                          highlightColor: const Color(0xFF00dbde),
                          period: const Duration(seconds: 3),
                          direction: ShimmerDirection.ltr,
                          child: Text(
                            "Codemixed Text Generator",
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).indicatorColor,
                              fontSize: 40,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Save your time! Get Marlish (English+Marathi) code-mixed text generated in few clicks.",
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).indicatorColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: TextField(
                    controller: _source,
                    maxLines: 3,
                    cursorColor: Theme.of(context).primaryColor,
                    cursorHeight: 25,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Theme.of(context).indicatorColor,
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter English Sentence",
                      filled: true,
                      fillColor: Theme.of(context).backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          width: 3,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: TextField(
                    controller: _target,
                    maxLines: 3,
                    cursorColor: Theme.of(context).primaryColor,
                    cursorHeight: 25,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Theme.of(context).indicatorColor,
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter Marathi Sentence",
                      filled: true,
                      fillColor: Theme.of(context).backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          width: 3,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                _isLoading
                    ? SpinKitDancingSquare(
                        color: Theme.of(context).primaryColor,
                        size: 50,
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: TextField(
                          controller: _output,
                          maxLines: 3,
                          cursorColor: Theme.of(context).primaryColor,
                          cursorHeight: 25,
                          style: GoogleFonts.poppins(
                            color: Theme.of(context).indicatorColor,
                            fontSize: 20,
                          ),
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: "Code Mixed Sentence",
                            filled: true,
                            fillColor: Theme.of(context).backgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                width: 3,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                _isLoading
                    ? Text(
                        "SIT BACK & RELAX!",
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).indicatorColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : ElevatedButton(
                        style: ButtonStyle(
                          minimumSize:
                              MaterialStateProperty.all(const Size(200, 50)),
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          )),
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor),
                          textStyle: MaterialStateProperty.all(
                            GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        onPressed: () async => await _validate(),
                        child: const Text("GENERATE CODE MIXED TEXT"),
                      ),
                const SizedBox(height: 20),
                Text(
                  "A Semester 7 NLP Lab Mini Project.",
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).indicatorColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    "Yash Lalit, Vishnu Menon, Piyush Joshi, Chinmay Malkar, Samik Koul",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).indicatorColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
