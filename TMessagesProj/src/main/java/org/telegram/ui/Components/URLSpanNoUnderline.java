/*
 * This is the source code of Telegram for Android v. 5.x.x.
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Nikolai Kudashov, 2013-2018.
 */

package org.telegram.ui.Components;

import android.net.Uri;
import android.text.TextPaint;
import android.text.style.URLSpan;
import android.view.View;

import org.telegram.messenger.browser.Browser;
import org.telegram.tgnet.TLObject;

public class URLSpanNoUnderline extends URLSpan {

    private boolean forceNoUnderline = false;
    private TextStyleSpan.TextStyleRun style;
    private TLObject object;

    // Used to label video timestamps
    public String label;

    public URLSpanNoUnderline(String url) {
        this(url, null);
    }

    public URLSpanNoUnderline(String url, boolean forceNoUnderline) {
        this(url, null);
        this.forceNoUnderline = forceNoUnderline;
    }

    public URLSpanNoUnderline(String url, TextStyleSpan.TextStyleRun run) {
        super(url != null ? url.replace('\u202E', ' ') : url);
        style = run;
    }

    @Override
    public void onClick(View widget) {
        String url = getURL();
        // MODIFIED: Block @ mentions and force external browser for all links
        if (url.startsWith("@")) {
            // Block opening @ mentions - they would open channels/users internally
            // Instead, force to external browser which won't open the app
            Uri uri = Uri.parse("https://t.me/" + url.substring(1));
            Browser.openUrl(widget.getContext(), uri, false, false, false, null, null, false, false, false);
        } else {
            // Force all links to open in external browser
            Browser.openUrl(widget.getContext(), url, false, false, false, null, null, false, false, false);
        }
    }

    @Override
    public void updateDrawState(TextPaint p) {
        int l = p.linkColor;
        int c = p.getColor();
        super.updateDrawState(p);
        if (style != null) {
            style.applyStyle(p);
        }
        p.setUnderlineText(l == c && !forceNoUnderline);
    }

    public void setObject(TLObject spanObject) {
        this.object = spanObject;
    }

    public TLObject getObject() {
        return object;
    }
}
