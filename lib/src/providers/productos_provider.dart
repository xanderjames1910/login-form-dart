import 'dart:convert';
import 'dart:io';

import 'package:form_validation/src/models/producto_model.dart';
import 'package:form_validation/src/preferencias_usuario/preferencias_usuario.dart';
import 'package:form_validation/src/secrets/secret_constants.dart' as secrets;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';

class ProductosProvider {
  final String _url = secrets.firebaseDBUrl;
  final _prefs = new PreferenciasUsuario();

  Future<bool> crearProducto(ProductoModel producto) async {
    final url = '$_url/productos.json?auth=${_prefs.token}';

    final resp =
        await http.post(Uri.parse(url), body: productoModelToJson(producto));

    final decodedData = json.decode(resp.body);

    print(decodedData);

    return true;
  }

  Future<bool> editarProducto(ProductoModel producto) async {
    final url = '$_url/productos/${producto.id}.json?auth=${_prefs.token}';

    final resp =
        await http.put(Uri.parse(url), body: productoModelToJson(producto));

    final decodedData = json.decode(resp.body);

    print(decodedData);

    return true;
  }

  Future<List<ProductoModel>> cargarProductos() async {
    final url = '$_url/productos.json?auth=${_prefs.token}';
    final resp = await http.get(Uri.parse(url));

    final Map<String, dynamic> decodedData = json.decode(resp.body);
    final List<ProductoModel> productos = new List();

    if (decodedData == null) return [];

    decodedData.forEach((id, prod) {
      final prodTemp = ProductoModel.fromJson(prod);
      prodTemp.id = id;

      productos.add(prodTemp);
    });

    // print(productos);

    return productos;
  }

  Future<int> borrarProducto(String id) async {
    final url = '$_url/productos/$id.json?auth=${_prefs.token}';

    final resp = await http.delete(Uri.parse(url));

    print(resp.body);

    return 1;
  }

  Future<String> subirImage(File imagen) async {
    final url = Uri.parse(secrets.cloudinaryUrl);

    final mimeType = mime(imagen.path).split('/');

    final imageUploadRequest = http.MultipartRequest(
      'POST',
      url,
    );

    final file = await http.MultipartFile.fromPath(
      'file',
      imagen.path,
      contentType: MediaType(mimeType[0], mimeType[1]),
    );

    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();

    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('Algo salió mal');
      print(resp.body);
      return null;
    }

    final responseData = json.decode(resp.body);

    print(responseData);

    return responseData['secure_url'];
  }
}
