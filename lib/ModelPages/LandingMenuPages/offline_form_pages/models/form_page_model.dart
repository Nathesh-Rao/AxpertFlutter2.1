import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/models/form_field_model.dart';

class OfflineFormPageModel {
  final String transId;
  final String caption;
  final bool visible;
  final bool attachments;
  final List<OfflineFormFieldModel> fields;
  Map<String, dynamic> schema;

  OfflineFormPageModel({
    required this.transId,
    required this.caption,
    required this.visible,
    required this.attachments,
    required this.fields,
    required this.schema,
  });

  factory OfflineFormPageModel.fromJson(Map<String, dynamic> json) {
    return OfflineFormPageModel(
      transId: json['transid'],
      caption: json['caption'],
      visible: json['visible'] ?? true,
      attachments: json['attachments'] ?? false,
      fields: (json['fields'] as List<dynamic>)
          .map((e) => OfflineFormFieldModel.fromJson(e))
          .toList()
        ..sort(
          (a, b) => a.order.compareTo(b.order),
        ),
      schema: json,
    );
  }
}
