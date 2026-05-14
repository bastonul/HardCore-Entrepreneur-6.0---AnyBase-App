package com.solidground.anybase.service;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.ResponseEntity;
import tools.jackson.databind.node.ObjectNode;
import tools.jackson.databind.node.ArrayNode;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.JsonNode;
//quiz management rn
@Service
public class CognitiveService {

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    @Value("${anybase.ai.url}")
    private String apiURL;
    @Value("${anybase.ai.model}")
    private String aiModel;

    public CognitiveService(RestTemplate aiRestTemplate)
    {
        this.restTemplate = aiRestTemplate;
        this.objectMapper = new ObjectMapper();
    }

    public String processText(String inputText, String profile) {
        try {
            ObjectNode requestBody = objectMapper.createObjectNode();
            requestBody.put("model", aiModel);
            requestBody.put("temperature", 0.2); //logic optimized

            ObjectNode responseFormat = objectMapper.createObjectNode(); //JSON RESPONSE
            responseFormat.put("type" , "json_object");
            requestBody.set("response_format", responseFormat);

            ArrayNode messages = requestBody.putArray("messages");

            ObjectNode systemMessage = objectMapper.createObjectNode();
            systemMessage.put("role", "system");
            systemMessage.put("content", getSystemPromptForProfile(profile));
            messages.add(systemMessage);

            ObjectNode userMessage = objectMapper.createObjectNode();
            userMessage.put("role", "user");
            userMessage.put("content", inputText);
            messages.add(userMessage);

            HttpEntity<String> request = new HttpEntity<>(requestBody.toString()); //proxy network call

            ResponseEntity<String> response = restTemplate.postForEntity(apiURL, request, String.class);

            JsonNode responseJson = objectMapper.readTree(response.getBody());
            return responseJson.get("choices").get(0).get("message").get("content").asText();

        } catch (Exception e) {
            e.printStackTrace();
            return "{\"error\": \"Processing failed. Verify system logs.\"}";
        }
    }


    private String getSystemPromptForProfile(String profile) {

        if ("ADHD".equalsIgnoreCase(profile)) {
            return "You are an expert cognitive translator specializing in ADHD accessibility. " +
                    "Your task is to transform the input text into a series of highly stimulating flashcards. " +
                    "RULES FOR ADHD: " +
                    "1. Micro-learning: Each card must contain ONLY ONE core concept or action. Strip away all fluff, filler words, and long-winded tangents. " +
                    "2. Low Cognitive Load: Use active voice and short, punchy sentences. Do not overwhelm the reader's working memory. " +
                    "3. High Impact: Make the information feel dynamic and direct. State the 'bottom line' immediately. " +
                    "FORMAT: Analyze the text and provide a highly concise, 2-3 word title. " +
                    "Output ONLY a valid JSON object with exactly two keys: 'title' (the short string) and 'cards' (an array of strings, where each string is a strictly formatted flashcard).";

        }
        else if("AUTISM".equalsIgnoreCase(profile)){
            return "You are an expert cognitive translator specializing in Autism Spectrum accessibility. " +
                   "Your task is to rewrite the input text into highly structured, literal, and predictable information cards. " +
                    "RULES FOR AUTISM: "
            +        "1. Absolute Literalism: Eradicate all idioms, metaphors, figures of speech, and sarcasm. Translate figurative concepts into concrete, objective facts. " +
                    "2. No Implied Meanings: Do not expect the reader to 'read between the lines'. Make all hidden context, emotions, or social nuances explicitly clear and logical. " +
                    "3. Neutral & Objective Tone: Present the information factually. Avoid emotional fluff, ambiguous adjectives, or confusing rhetoric. " +
                    "FORMAT: Analyze the text and provide a highly concise, 2-3 word title. " +
                    "Output ONLY a valid JSON object with exactly two keys: 'title' (the short string) and 'cards' (an array of strings, where each string is a clear, literal paragraph).";
        }
        else if("AUDIO_TTS".equalsIgnoreCase(profile)) {
            return "You are an expert audio-formatting AI, specializing in pacing text for Text-to-Speech (TTS) engines and auditory processing. " +
                    "Your task is to segment the input text into perfectly paced audio chunks without losing a single word. " +
                    "RULES FOR AUDIO: " +
                    "1. Zero Alteration: You must NOT summarize, paraphrase, or delete any information. Preserve the exact original text completely. " +
                    "2. Rhythmic Pacing: Break the text into small, digestible chunks (1-3 sentences per card). This provides natural 'breathing pauses' for both the TTS engine and the listener's working memory. " +
                    "3. Phonetic Flow: Ensure every chunk ends on a hard punctuation mark (period, exclamation, or question mark) so the audio engine naturally lowers its pitch before transitioning to the next card. " +
                    "FORMAT: Analyze the text and provide a highly concise, 2-3 word title. " +
                    "Output ONLY a valid JSON object with exactly two keys: 'title' (the short string) and 'cards' (an array of strings, containing the segmented original text).";
        }
        else if ("DYSLEXIA".equalsIgnoreCase(profile)) {
            return "You are an expert cognitive translator specializing in Dyslexia accessibility. " +
                    "Your task is to simplify the visual and cognitive decoding process of the input text. " +
                    "RULES FOR DYSLEXIA: " +
                    "1. Clear & Common Vocabulary: Avoid visually complex words, dense jargon, or words with easily confused letters (like b/d/p/q). Replace them with simple, common equivalents. " +
                    "2. Linear Sentence Structure: Write in very short, straightforward sentences. Strictly avoid nested clauses or passive voice that require the reader's eyes to track back and forth. " +
                    "3. Anti-Crowding: Keep each card extremely brief (1-2 sentences maximum) to prevent visual crowding and reading fatigue. " +
                    "FORMAT: Analyze the text and provide a highly concise, 2-3 word title. " +
                    "Output ONLY a valid JSON object with exactly two keys: 'title' (the short string) and 'cards' (an array of strings, where each string is a highly readable card).";
        }
        return "You are an AI cognitive assistant. Your task is to summarize the input text clearly and logically. " + //default fallback
                "Break down the information into easy-to-read, standalone flashcards. " +
                "Analyze the text and provide a highly concise, 2-3 word title representing its main topic. " +
                "Output ONLY a valid JSON object with exactly two keys: 'title' (the short string) and 'cards' (an array of strings containing the summarized points).";


    }
    public String generateQuiz(String inputText, String profile) { //quiz "logic"
        try {
            ObjectNode requestBody = objectMapper.createObjectNode();
            requestBody.put("model", aiModel);
            requestBody.put("temperature", 0.4);

            ObjectNode responseFormat = objectMapper.createObjectNode();
            responseFormat.put("type" , "json_object");
            requestBody.set("response_format", responseFormat);

            ArrayNode messages = requestBody.putArray("messages");

            ObjectNode systemMessage = objectMapper.createObjectNode();
            systemMessage.put("role", "system");
            systemMessage.put("content", "You are an educational AI. Based ONLY on the user's provided text, generate exactly 4 multiple-choice questions. " +
                    "Output ONLY a valid JSON object with a single key 'questions'. The value must be an array of objects. " +
                    "Each object must have: 'q' (the question text), 'options' (an array of exactly 3 possible answer strings), and 'answer' (the exact correct string from the options).");
            messages.add(systemMessage);

            ObjectNode userMessage = objectMapper.createObjectNode();
            userMessage.put("role", "user");
            userMessage.put("content", inputText);
            messages.add(userMessage);

            HttpEntity<String> request = new HttpEntity<>(requestBody.toString());
            ResponseEntity<String> response = restTemplate.postForEntity(apiURL, request, String.class);

            JsonNode responseJson = objectMapper.readTree(response.getBody());
            return responseJson.get("choices").get(0).get("message").get("content").asText();

        } catch (Exception e) {
            e.printStackTrace();
            return "{\"error\": \"Quiz generation failed.\"}";
        }
    }
}



