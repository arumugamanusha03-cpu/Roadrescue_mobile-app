import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/service_type.dart';
import '../../core/constants/vehicle_type.dart';

/// A photo the customer attached. Bytes (not a file path) so it previews
/// the same way on Android, iOS and web.
class PickedPhoto {
  const PickedPhoto({required this.bytes, required this.name});

  final Uint8List bytes;
  final String name;
}

/// A voice description recorded on this device. Only the local file path
/// is kept; nothing is uploaded until a backend exists.
class VoiceNote {
  const VoiceNote({required this.path, required this.duration});

  /// File path on Android/iOS; a blob URL on web.
  final String path;
  final Duration duration;
}

/// Everything collected across the five request steps.
class RequestDraft {
  const RequestDraft({
    this.service,
    this.vehicleType = VehicleType.car,
    this.brand,
    this.model,
    this.registration = '',
    this.fuelType,
    this.vehiclePhoto,
    this.location,
    this.address,
    this.photos = const [],
    this.notes = '',
    this.voiceNote,
  });

  final ServiceType? service;
  final VehicleType vehicleType;
  final String? brand;
  final String? model;
  final String registration;
  final String? fuelType;
  final PickedPhoto? vehiclePhoto;
  final LatLng? location;
  final String? address;
  final List<PickedPhoto> photos;
  final String notes;
  final VoiceNote? voiceNote;

  String get vehicleName => [?brand, ?model].join(' ');

  bool get hasVehicle =>
      brand != null && model != null && registration.trim().isNotEmpty;

  RequestDraft copyWith({
    ServiceType? service,
    VehicleType? vehicleType,
    String? brand,
    String? model,
    String? registration,
    String? fuelType,
    PickedPhoto? vehiclePhoto,
    LatLng? location,
    String? address,
    List<PickedPhoto>? photos,
    String? notes,
    VoiceNote? voiceNote,
    bool clearVoiceNote = false,
    bool clearBrand = false,
    bool clearModel = false,
    bool clearFuel = false,
    bool clearVehiclePhoto = false,
  }) {
    return RequestDraft(
      service: service ?? this.service,
      vehicleType: vehicleType ?? this.vehicleType,
      brand: clearBrand ? null : brand ?? this.brand,
      model: clearModel ? null : model ?? this.model,
      registration: registration ?? this.registration,
      fuelType: clearFuel ? null : fuelType ?? this.fuelType,
      vehiclePhoto: clearVehiclePhoto
          ? null
          : vehiclePhoto ?? this.vehiclePhoto,
      location: location ?? this.location,
      address: address ?? this.address,
      photos: photos ?? this.photos,
      notes: notes ?? this.notes,
      voiceNote: clearVoiceNote ? null : voiceNote ?? this.voiceNote,
    );
  }
}

class RequestDraftController extends Notifier<RequestDraft> {
  @override
  RequestDraft build() => const RequestDraft();

  void selectService(ServiceType service) =>
      state = state.copyWith(service: service);

  /// Switching vehicle type clears brand/model/fuel, which differ per type.
  void selectVehicleType(VehicleType type) {
    if (type == state.vehicleType) return;
    state = state.copyWith(
      vehicleType: type,
      clearBrand: true,
      clearModel: true,
      clearFuel: true,
    );
  }

  /// Fills the vehicle step from a saved vehicle.
  void useVehicle({
    required VehicleType type,
    required String brand,
    required String model,
    required String registration,
    required String fuelType,
    PickedPhoto? photo,
  }) {
    state = state.copyWith(
      vehicleType: type,
      brand: brand,
      model: model,
      registration: registration,
      fuelType: fuelType,
      vehiclePhoto: photo,
    );
  }

  void setBrand(String brand) =>
      state = state.copyWith(brand: brand, clearModel: true);

  void setModel(String model) => state = state.copyWith(model: model);

  void setRegistration(String value) =>
      state = state.copyWith(registration: value);

  void setFuelType(String fuel) => state = state.copyWith(fuelType: fuel);

  void setVehiclePhoto(PickedPhoto? photo) => state = photo == null
      ? state.copyWith(clearVehiclePhoto: true)
      : state.copyWith(vehiclePhoto: photo);

  void setLocation(LatLng location, String address) =>
      state = state.copyWith(location: location, address: address);

  void addPhoto(PickedPhoto photo) =>
      state = state.copyWith(photos: [...state.photos, photo]);

  void removePhoto(int index) =>
      state = state.copyWith(photos: [...state.photos]..removeAt(index));

  void setNotes(String notes) => state = state.copyWith(notes: notes);

  void setVoiceNote(VoiceNote note) => state = state.copyWith(voiceNote: note);

  void clearVoiceNote() => state = state.copyWith(clearVoiceNote: true);

  void reset() => state = const RequestDraft();
}

final requestDraftProvider =
    NotifierProvider<RequestDraftController, RequestDraft>(
      RequestDraftController.new,
    );
