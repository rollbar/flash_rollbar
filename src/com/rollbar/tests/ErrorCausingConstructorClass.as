package com.rollbar.tests {
    public class ErrorCausingConstructorClass {
        public function ErrorCausingConstructorClass() {
            throw new Error('dummy');
        }
    }
}