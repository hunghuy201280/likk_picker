import 'package:flutter/material.dart';
import 'package:likk_picker/likk_picker.dart';

import 'grid_view_widget.dart';

///
class CollapsableGallery extends StatefulWidget {
  ///
  const CollapsableGallery({
    Key? key,
  }) : super(key: key);

  @override
  _CollapsableGalleryState createState() => _CollapsableGalleryState();
}

class _CollapsableGalleryState extends State<CollapsableGallery> {
  late final GalleryController controller;
  late final ValueNotifier<List<LikkEntity>> notifier;

  @override
  void initState() {
    super.initState();
    notifier = ValueNotifier(<LikkEntity>[]);
    controller = GalleryController(
      gallerySetting: const GallerySetting(
        enableCamera: false,
        maximum: 2,
        requestType: RequestType.all,
        actionButton: null,
        albumTitleStyle: TextStyle(fontSize: 16),
        albumBackground: ColoredBox(
          color: Colors.white,
        ),
        albumColor: Colors.lightBlueAccent,
        crossAxisCount: 4,
      ),
      panelSetting: const PanelSetting(
        // background: Image.asset('../assets/bg.jpeg', fit: BoxFit.cover),
        background: ColoredBox(
          color: Colors.lightBlueAccent,
        ),
      ),
      headerSetting: const HeaderSetting(
          headerLeftWidget: Text(
            "Hủy",
            style: TextStyle(color: Colors.white),
          ),
          headerCenterWidget: Text("Hello"),
          headerMaxHeight: 80,
          barSize: Size(100, 4),
          barColor: Colors.white,
          headerBackground: ColoredBox(
            color: Colors.lightBlueAccent,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          headerRightWidget: Text(
            "Album",
            style: TextStyle(color: Colors.white),
          )),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PlaygroundController? playgroundController;
    return GalleryViewWrapper(
      controller: controller,
      safeAreaBottom: true,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.amber,
          appBar: AppBar(
            title: const Text('Pick using picker view'),
          ),
          body: Column(
            children: [
              // Grid view
              Expanded(
                child: GridViewWidget(
                  notifier: notifier,
                  isPlayground: true,
                  onCreated: (ctl) => playgroundController = ctl,
                ),
              ),
              //
              Builder(builder: (context) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        playgroundController?.updateValue(hasFocus: true);
                      },
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Add Text'),
                    ),
                    const SizedBox(width: 20),
                    TextButton(
                      onPressed: () async {
                        final entities = await controller.pick(
                          context,
                          selectedEntities: notifier.value,
                        );
                        notifier.value = entities;
                      },
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Use Controller'),
                    ),
                    const SizedBox(width: 20),
                    TextButton(
                      onPressed: () {
                        playgroundController?.takeScreenshot();
                      },
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Capture'),
                    ),
                  ],
                );
              }),

              // Textfield
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // Textfield
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Test field',
                        ),
                      ),
                    ),

                    // Camera field..
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CameraViewField(
                        onCapture: (entity) {
                          notifier.value = [...notifier.value, entity];
                        },
                        child: const Icon(Icons.camera),
                      ),
                    ),

                    // Gallery field
                    ValueListenableBuilder<List<LikkEntity>>(
                      valueListenable: notifier,
                      builder: (context, list, child) {
                        return GalleryViewField(
                          controller: controller,
                          selectedEntities: list,
                          onChanged: (entity, isRemoved) {
                            final value = notifier.value.toList();
                            if (isRemoved) {
                              value.remove(entity);
                            } else {
                              value.add(entity);
                            }
                            notifier.value = value;
                          },
                          onSubmitted: (list) {
                            notifier.value = list;
                          },
                          child: child,
                        );
                      },
                      child: const Icon(Icons.photo),
                    ),

                    //
                  ],
                ),
              ),

              //
            ],
          ),
        ),
      ),
    );
  }
}
