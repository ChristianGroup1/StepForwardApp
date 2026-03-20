# Keep Flutter core classes
-keep class io.flutter.** { *; }
-keep class com.google.firebase.** { *; }

# Keep your app classes
-keep class com.stepforward.** { *; }

# Keep gRPC and OkHttp classes
-keep class io.grpc.** { *; }
-keep class com.squareup.okhttp.** { *; }
-keep class com.squareup.okhttp3.** { *; }

# Keep all model classes
-keepclassmembers class ** {
    public <methods>;
    public <fields>;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Remove unused resources
-dontwarn com.google.**
-dontwarn android.**
-dontwarn io.grpc.**
-dontwarn com.squareup.okhttp.**
-dontwarn com.squareup.okhttp3.**