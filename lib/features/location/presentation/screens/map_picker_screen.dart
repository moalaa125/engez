import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:engez/constants/my_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:engez/widgets/custom_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';


class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? _selectedLocation;
  final MapController _mapController = MapController();
  bool _isLoadingLocation = true;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isFetchingCurrentLocation = false;
  Timer? _debounce;
  List<Map<String, dynamic>> _searchResults = [];
  final FocusNode _searchFocusNode = FocusNode();


  Future<void> _onSearchChanged(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    
    _debounce = Timer(const Duration(milliseconds: 800), () async {
      try {
        final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&addressdetails=1&countrycodes=eg');
        final response = await http.get(url, headers: {'User-Agent': 'com.example.engez'});
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as List;
          setState(() {
            _searchResults = data.map((e) => {
              'display_name': e['display_name'],
              'lat': double.parse(e['lat'].toString()),
              'lon': double.parse(e['lon'].toString()),
            }).toList();
          });
        }
      } catch (e) {
        // Handle silently
      } finally {
        if (mounted) setState(() => _isSearching = false);
      }
    });
  }

  void _selectSearchResult(Map<String, dynamic> result) {
    final newLocation = LatLng(result['lat'], result['lon']);
    setState(() {
      _selectedLocation = newLocation;
      _searchResults = [];
      _searchController.text = result['display_name'].toString().split(',').first;
    });
    _searchFocusNode.unfocus();
    _mapController.move(newLocation, 15.0);
  }
  
  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }



  Future<void> _moveToCurrentLocation() async {
    setState(() => _isFetchingCurrentLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى تفعيل الـ GPS', style: TextStyle(fontFamily: 'Cairo'))));
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          return;
        }
      }
      
      Position position = await Geolocator.getCurrentPosition();
      final newLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedLocation = newLocation;
      });
      _mapController.move(newLocation, 15.0);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل في تحديد الموقع الحالي', style: TextStyle(fontFamily: 'Cairo'))));
    } finally {
      if (mounted) setState(() => _isFetchingCurrentLocation = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setDefaultLocation();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _setDefaultLocation();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _setDefaultLocation();
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
    } catch (e) {
      _setDefaultLocation();
    }
  }

  void _setDefaultLocation() {
    setState(() {
      _selectedLocation = const LatLng(30.0444, 31.2357); // Default to Cairo
      _isLoadingLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoadingLocation
          ? const Center(child: CircularProgressIndicator(color: MyColors.myOrange))
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation!,
                    initialZoom: 15.0,
                    minZoom: 5.0,
                    cameraConstraint: CameraConstraint.contain(
                      bounds: LatLngBounds(
                        const LatLng(21.0, 24.0), // SouthWest
                        const LatLng(32.0, 37.0), // NorthEast
                      ),
                    ),
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedLocation = point;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.engez',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: _selectedLocation!,
                          child: const Icon(
                            Icons.location_on,
                            color: MyColors.myOrange,
                            size: 50.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 10.h,
                  left: 20.w,
                  right: 20.w,
                  child: SafeArea(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'ابحث عن مدينة أو منطقة...',
                              hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                              prefixIcon: IconButton(
                                icon: const Icon(Icons.arrow_back, color: MyColors.myDarkText),
                                onPressed: () => Navigator.pop(context),
                              ),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_isSearching)
                                    Transform.scale(scale: 0.5, child: const CircularProgressIndicator(color: MyColors.myOrange, strokeWidth: 3))
                                  else if (_searchController.text.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 12.0),
                                      child: Icon(Icons.search, color: MyColors.myOrange),
                                    ),
                                  if (_searchController.text.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.clear, color: MyColors.myDarkText, size: 20),
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (_searchResults.isNotEmpty)
                            Container(
                              constraints: BoxConstraints(maxHeight: 200.h),
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final result = _searchResults[index];
                                  return Material(
                                    color: Colors.transparent,
                                    child: ListTile(
                                      leading: const Icon(Icons.location_on, color: MyColors.myTextSecondary),
                                      title: Text(
                                        result['display_name'],
                                        style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textDirection: TextDirection.rtl,
                                      ),
                                      onTap: () => _selectSearchResult(result),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 100.h,
                  right: 20.w,
                  child: FloatingActionButton(
                    backgroundColor: MyColors.myWhite,
                    onPressed: _isFetchingCurrentLocation ? null : _moveToCurrentLocation,
                    child: _isFetchingCurrentLocation 
                      ? const CircularProgressIndicator(color: MyColors.myOrange)
                      : const Icon(Icons.my_location, color: MyColors.myOrange),
                  ),
                ),
                Positioned(
                  bottom: 30.h,
                  left: 0,
                  right: 0,
                  child: CustomButton(
                    text: 'تأكيد الموقع',
                    buttonColor: MyColors.myOrange,
                    textColor: Colors.white,
                    function: () {
                      Navigator.pop(context, {
                        'latitude': _selectedLocation!.latitude,
                        'longitude': _selectedLocation!.longitude,
                      });
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
