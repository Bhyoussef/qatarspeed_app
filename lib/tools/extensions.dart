extension GetAttrib on Map {
  dynamic get(String key) {
    if (!containsKey(key)) {
      return null;
    }
    return this[key];
  }
}