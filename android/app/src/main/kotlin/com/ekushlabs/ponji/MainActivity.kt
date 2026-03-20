// android/app/src/main/kotlin/com/ekushlabs/ponji/MainActivity.kt

package com.ekushlabs.ponji

import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import android.content.Context
import android.view.LayoutInflater
import android.widget.TextView
import android.widget.Button
import android.widget.ImageView

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register the NativeAdFactory so Flutter can render native ads
        // using our custom layout defined in res/layout/native_ad.xml
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "ekushNativeAd",
            EkushNativeAdFactory(context)
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        // Always unregister to avoid memory leaks
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "ekushNativeAd")
        super.cleanUpFlutterEngine(flutterEngine)
    }
}

// ── Native Ad Factory ─────────────────────────────────────────────────────────
// Inflates our custom native_ad.xml layout and binds AdMob ad assets to views.

class EkushNativeAdFactory(private val context: Context) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val inflater = LayoutInflater.from(context)
        val adView = inflater.inflate(R.layout.native_ad, null) as NativeAdView

        // Headline
        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        headlineView.text = nativeAd.headline
        adView.headlineView = headlineView

        // Body
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        if (nativeAd.body != null) {
            bodyView.text = nativeAd.body
            bodyView.visibility = android.view.View.VISIBLE
        } else {
            bodyView.visibility = android.view.View.GONE
        }
        adView.bodyView = bodyView

        // Advertiser
        val advertiserView = adView.findViewById<TextView>(R.id.ad_advertiser)
        if (nativeAd.advertiser != null) {
            advertiserView.text = nativeAd.advertiser
            advertiserView.visibility = android.view.View.VISIBLE
        } else {
            advertiserView.visibility = android.view.View.GONE
        }
        adView.advertiserView = advertiserView

        // Call to action button
        val ctaView = adView.findViewById<Button>(R.id.ad_call_to_action)
        if (nativeAd.callToAction != null) {
            ctaView.text = nativeAd.callToAction
            ctaView.visibility = android.view.View.VISIBLE
        } else {
            ctaView.visibility = android.view.View.GONE
        }
        adView.callToActionView = ctaView

        // Icon
        val iconView = adView.findViewById<ImageView>(R.id.ad_icon)
        if (nativeAd.icon != null) {
            iconView.setImageDrawable(nativeAd.icon!!.drawable)
            iconView.visibility = android.view.View.VISIBLE
        } else {
            iconView.visibility = android.view.View.GONE
        }
        adView.iconView = iconView

        // Register the native ad — required to record impressions and clicks
        adView.setNativeAd(nativeAd)

        return adView
    }
}