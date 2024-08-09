import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bluejobs/styles/custom_button.dart';
import 'package:bluejobs/styles/responsive_utils.dart';
import 'package:bluejobs/styles/textstyle.dart';

class FindOthersPage extends StatefulWidget {
  const FindOthersPage({Key? key}) : super(key: key);

  @override
  State<FindOthersPage> createState() => _FindOthersPageState();
}

class _FindOthersPageState extends State<FindOthersPage> {
  bool isLoading = false;
  bool showCards = false;
  bool showButton = true;
  Position? currentPosition;

  List<Map<String, dynamic>> workers = [
   
  ];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (await Permission.location.isGranted) {
      setState(() {
        showButton = true;
      });
    } else {
      PermissionStatus status = await Permission.location.request();
      if (status.isGranted) {
        setState(() {
          showButton = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Location permission is required to find the nearest worker')),
        );
      }
    }
  }

  Future<void> _startLoading() async {
    setState(() {
      isLoading = true;
      showButton = false;
    });
    await Future.delayed(const Duration(seconds: 5)); // Simulate loading delay
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        isLoading = false;
        showCards = true; // Show cards after loading
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showResumeModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color.fromARGB(255, 7, 30, 47),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              // Detect horizontal swipe to close dialog
              if (details.primaryDelta! > 10) {
                Navigator.of(context).pop();
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildResumeItem(context, 'Name', 'Mark Angelo Cid'),
                            buildResumeItem(context, 'Age', '21'),
                            buildResumeItem(
                                context, 'Contact Number', '09637077358'),
                            buildResumeItem(context, 'Sex', 'Male'),
                            buildResumeItem(
                                context, 'Address', 'San Antonio, Tabaco City'),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10.0, top: 5.0),
                              child: Text(
                                'I am mostly good at!',
                                style: CustomTextStyle.regularText.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: responsiveSize(context, 0.03),
                                ),
                              ),
                            ),
                            buildSpecializationChips(
                                ['Housecleaning', 'Eating']),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeWorker(int index) {
    setState(() {
      workers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBarColor =
        const Color.fromARGB(255, 7, 30, 47); // Color same as AppBar

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Find Others',
          style: CustomTextStyle.semiBoldText
              .copyWith(fontSize: responsiveSize(context, 0.04)),
        ),
      ),

      // body: showButton
      //     ? Center(
      //         child: CustomButton(
      //           onTap: _startLoading,
      //           buttonText: 'Find workers near me',
      //         ),
      //       )
      body: showButton
          ? Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0), // Adjust the horizontal padding as needed
              child: Column(
                children: [
                  const SizedBox(
                      height: 120), // This creates the space below the AppBar
                  Center(
                    child: CustomButton(
                      buttonText: 'Find workers near me',
                      onPressed: () {
                        _startLoading();
                      },
                    ),
                  ),
                ],
              ),
            )
          : isLoading
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 120),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                                color: Colors.white),
                            const SizedBox(height: 16),
                            Text(
                              'Wait for a few seconds...',
                              style: CustomTextStyle.regularText.copyWith(
                                  fontSize: responsiveSize(context, 0.04)),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : showCards
                  ? CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          backgroundColor: appBarColor,
                          pinned: true,
                          expandedHeight: 60.0,
                          flexibleSpace: FlexibleSpaceBar(
                            title: Text(
                              'Here are the workers near you',
                              style: CustomTextStyle.regularText.copyWith(
                                  fontSize: responsiveSize(context, 0.03)),
                            ),
                            titlePadding: const EdgeInsets.all(13),
                            collapseMode: CollapseMode.pin,
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0), // Space from sides
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final worker = workers[index];
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  color: appBarColor,
                                  elevation: 4.0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Stack(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundImage: AssetImage(
                                                      worker['profilePic']),
                                                  radius: 30,
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(worker['name'],
                                                          style: CustomTextStyle
                                                              .semiBoldText
                                                              .copyWith(
                                                                  fontSize:
                                                                      responsiveSize(
                                                                          context,
                                                                          0.04))),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                              Icons.location_on,
                                                              color:
                                                                  Colors.white,
                                                              size: 16),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(worker['place'],
                                                              style: CustomTextStyle
                                                                  .regularText),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                                height:
                                                    16), // Space between profile info and buttons
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    onPressed: () {
                                                      // Handle view resume action
                                                    },
                                                    onLongPress: () {
                                                      _showResumeModal(context);
                                                    },
                                                    icon: Icon(
                                                        Icons.remove_red_eye,
                                                        color: Colors.white),
                                                    label: Text('See Resume',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: CustomTextStyle
                                                            .regularText),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            backgroundColor:
                                                                const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    243,
                                                                    107,
                                                                    4)),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    onPressed: () {
                                                      // Handle message action
                                                    },
                                                    icon: Icon(Icons.message,
                                                        color: Colors.black),
                                                    label: Text(
                                                      'Message',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: CustomTextStyle
                                                          .regularText
                                                          .copyWith(
                                                              color:
                                                                  Colors.black),
                                                    ),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            backgroundColor:
                                                                const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Positioned(
                                          right: 10,
                                          top: 10,
                                          child: IconButton(
                                            icon: const Icon(Icons.close,
                                                color: Colors.white),
                                            onPressed: () {
                                              _removeWorker(index);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              childCount: workers.length,
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Above are the results, Take note that it can only reach up to 10kms of searching',
                              style: CustomTextStyle.regularText.copyWith(
                                  fontSize: responsiveSize(context, 0.03)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(), // Empty widget if nothing is shown
    );
  }

  Widget buildResumeItem(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$title: ',
              style: CustomTextStyle.regularText.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: responsiveSize(context, 0.03),
              ),
            ),
            TextSpan(
              text: content,
              style: CustomTextStyle.regularText.copyWith(
                fontSize: responsiveSize(context, 0.03),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSpecializationChips(List<String> specializations) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: specializations.map((specialization) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Chip(
            backgroundColor: const Color.fromARGB(255, 243, 107, 4),
            label: Text(
              specialization,
              style: CustomTextStyle.regularText.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
