package com.ekushlabs.ponji

import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import com.google.android.gms.ads.nativead.MediaView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.TextView
import android.widget.Button
import android.widget.ImageView

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "ekushNativeAd",
            EkushNativeAdFactory(context)
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "ekushNativeAd")
        super.cleanUpFlutterEngine(flutterEngine)
    }
}

class EkushNativeAdFactory(private val context: Context) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val inflater = LayoutInflater.from(context)
        val adView = inflater.inflate(R.layout.native_ad, null) as NativeAdView

        // ── MediaView ─────────────────────────────────────────────────────────
        // Keep media container visible so video/image creatives can render.
        // This also avoids native-validator "ad too small" issues caused by
        // collapsing required media area.
        val mediaView = adView.findViewById<MediaView>(R.id.ad_media)
        adView.mediaView = mediaView
        mediaView.visibility = View.VISIBLE

        // ── Headline ──────────────────────────────────────────────────────────
        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        headlineView.text = nativeAd.headline
        adView.headlineView = headlineView

        // ── Body ──────────────────────────────────────────────────────────────
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        if (nativeAd.body != null) {
            bodyView.text = nativeAd.body
            bodyView.visibility = View.VISIBLE
        } else {
            bodyView.visibility = View.GONE
        }
        adView.bodyView = bodyView

        // ── Advertiser ────────────────────────────────────────────────────────
        val advertiserView = adView.findViewById<TextView>(R.id.ad_advertiser)
        if (nativeAd.advertiser != null) {
            advertiserView.text = nativeAd.advertiser
            advertiserView.visibility = View.VISIBLE
        } else {
            advertiserView.visibility = View.GONE
        }
        adView.advertiserView = advertiserView

        // ── Call to action ────────────────────────────────────────────────────
        val ctaView = adView.findViewById<Button>(R.id.ad_call_to_action)
        if (nativeAd.callToAction != null) {
            ctaView.text = nativeAd.callToAction
            ctaView.visibility = View.VISIBLE
        } else {
            ctaView.visibility = View.GONE
        }
        adView.callToActionView = ctaView

        // ── Icon ──────────────────────────────────────────────────────────────
        val iconView = adView.findViewById<ImageView>(R.id.ad_icon)
        if (nativeAd.icon != null) {
            iconView.setImageDrawable(nativeAd.icon!!.drawable)
            iconView.visibility = View.VISIBLE
        } else {
            iconView.visibility = View.GONE
        }
        adView.iconView = iconView

        adView.setNativeAd(nativeAd)
        return adView
    }
}