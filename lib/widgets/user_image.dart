// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as p;
// import 'package:firebase_storage/firebase_storage.dart' as storage;
//
// import '../utils/dimensions.dart';
// import 'app_icon.dart';
//
// class UserImage extends StatefulWidget {
//   final Function(String imageUrl) onFileChanged;
//
//   UserImage({required this.onFileChanged});
//
//   @override
//   _UserImageState createState() => _UserImageState();
// }
//
// class _UserImageState extends State<UserImage> {
//   final ImagePicker _picker = ImagePicker();
//   String imageUrl = '';
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Container(
//           width: 130,
//           height: 130,
//           decoration: BoxDecoration(
//             color: Colors.grey.withOpacity(0.4),
//             border: Border.all(width: 2, color: Colors.white),
//             boxShadow: [
//               BoxShadow(
//                 spreadRadius: 2,
//                 blurRadius: 10,
//                 color: Colors.white.withOpacity(0.1),
//               ),
//             ],
//             shape: BoxShape.circle,
//             // image: DecorationImage(
//             //   opacity: 0.6,
//             //   fit: BoxFit.fitWidth,
//             //   image: AssetImage(
//             //       'assets/image/avatar.png'),
//             // ),
//           ),
//           child: imageUrl == ''
//               ? Icon(
//                   Icons.person,
//                   size: 80,
//                   color: Colors.white,
//                 )
//               : Image.network(imageUrl),
//         ),
//         Positioned(
//           right: 0.2,
//           top: 80,
//           child: InkWell(
//             splashColor: Colors.transparent,
//             highlightColor: Colors.transparent,
//             onTap: () => _selectPhoto(),
//             child: Container(
//                 decoration: BoxDecoration(
//                     color: const Color(0xfffefafa),
//                     borderRadius:
//                         BorderRadius.circular(Dimensions.height10 * 5),
//                     border: Border.all(
//                       width: 1,
//                       color: Colors.black26,
//                     )),
//                 child: AppIcon(
//                   icon: Icons.camera_alt_rounded,
//                   backgroundColor: Colors.white60,
//                   iconColor: Colors.black87,
//                   iconSize: Dimensions.height20,
//                   size: Dimensions.height20 + Dimensions.height15,
//                 )),
//           ),
//         )
//       ],
//     );
//   }
//
//   Future _selectPhoto() async {
//     await showModalBottomSheet(
//         context: context,
//         builder: (context) => BottomSheet(
//               builder: (context) => Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   ListTile(
//                     leading: Icon(Icons.camera),
//                     title: Text('Camera'),
//                     onTap: () {
//                       Navigator.of(context).pop();
//                       _pickImage(ImageSource.camera);
//                     },
//                   ),
//                   ListTile(
//                     leading: Icon(Icons.filter),
//                     title: Text('Pick a file'),
//                     onTap: () {
//                       Navigator.of(context).pop();
//                       _pickImage(ImageSource.gallery);
//                     },
//                   )
//                 ],
//               ),
//               onClosing: () {},
//             ));
//   }
//
//   Future _pickImage(ImageSource source) async {
//     try {
//       final XFile? pickedFile =
//           await _picker.pickImage(source: source, imageQuality: 50);
//       if (pickedFile == null) {
//         return;
//       }
//       var file = await ImageCropper().cropImage(
//           sourcePath: pickedFile.path,
//           aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1));
//       if (file == null) {
//         return;
//       }
//       file = (await compressImage(file.path, 35)) as CroppedFile?;
//     } catch (error) {
//       print('This is where the error is: $error');
//     }
//   }
//
//   Future<File> compressImage(String path, int quality) async {
//     final newPath = p.join((await getTemporaryDirectory()).path,
//         '${DateTime.now()}.${p.extension(path)}');
//
//     final result = await FlutterImageCompress.compressAndGetFile(path, newPath,
//         quality: quality);
//     return result!;
//   }
//
//   Future _uploadFile(String path) async {
//     final ref = storage.FirebaseStorage.instance
//         .ref()
//         .child('avatars')
//         .child('${DateTime.now().toIso8601String() + p.basename(path)}');
//
//     final result = await ref.putFile(File(path));
//     final fileUrl = await result.ref.getDownloadURL();
//
//     setState(() {
//       imageUrl = fileUrl;
//     });
//
//     widget.onFileChanged(fileUrl);
//   }
// }
