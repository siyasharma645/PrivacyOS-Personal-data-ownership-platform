package com.privacyos.exception;
import org.springframework.http.*;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;
import java.time.Instant;
import java.util.*;

@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(NotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(NotFoundException ex){
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorResponse("NOT_FOUND",ex.getMessage()));}
    @ExceptionHandler(ConflictException.class)
    public ResponseEntity<ErrorResponse> handleConflict(ConflictException ex){
        return ResponseEntity.status(HttpStatus.CONFLICT).body(new ErrorResponse("CONFLICT",ex.getMessage()));}
    @ExceptionHandler(UnauthorizedException.class)
    public ResponseEntity<ErrorResponse> handleUnauthorized(UnauthorizedException ex){
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(new ErrorResponse("UNAUTHORIZED",ex.getMessage()));}
    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<ErrorResponse> handleBadCreds(BadCredentialsException ex){
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(new ErrorResponse("INVALID_CREDENTIALS","Invalid email or password"));}
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex){
        Map<String,String> errors=new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach(e->errors.put(((FieldError)e).getField(),e.getDefaultMessage()));
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(new ErrorResponse("VALIDATION_ERROR","Validation failed",errors));}
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGeneral(Exception ex){
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(new ErrorResponse("INTERNAL_ERROR","An unexpected error occurred"));}
    public record ErrorResponse(String code,String message,Object details,Instant timestamp){
        public ErrorResponse(String c,String m){this(c,m,null,Instant.now());}
        public ErrorResponse(String c,String m,Object d){this(c,m,d,Instant.now());}
    }
}