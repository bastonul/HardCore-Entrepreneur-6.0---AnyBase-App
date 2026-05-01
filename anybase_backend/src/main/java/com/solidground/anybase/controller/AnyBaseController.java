package com.solidground.anybase.controller;
//REST controller handles incoming requests
import com.solidground.anybase.dto.TranslationRequest;
import com.solidground.anybase.service.CognitiveService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class AnyBaseController {

    private final CognitiveService cognitiveService;

    public AnyBaseController(CognitiveService cognitiveService){
        this.cognitiveService = cognitiveService;
    }

    //health endpoint
    @GetMapping("/test")
    public ResponseEntity<String> testServer(){
        return ResponseEntity.ok("AnyBase Server is online, proxy is active.");
    }

    //app endpoint
    @PostMapping("/adapt")
    public ResponseEntity<String> adaptText(@RequestBody TranslationRequest request){
        if(request.getText() == null || request.getText().trim().isEmpty()) {
            return ResponseEntity.badRequest().body("{\"error\": \"Empty or invalid Payload.\"}");
        }
        String resultJson = cognitiveService.processText(request.getText(), request.getProfile());
        return ResponseEntity.ok(resultJson);
    }
}
