package com.solidground.anybase.dto;

//data transfer object because flutter doesnt speak the same language as springboot (JSON payload to Java object)

public class TranslationRequest {
    private String text;
    private String profile; //ADHD, AUTISM, DYSLEXIA

    public String getText() {
        return text;
    }
    public String getProfile() {
        return profile;
    }
    public void setText(String text) {
        this.text = text;
    }
    public void setProfile(String profile) {
        this.profile = profile;
    }
}
