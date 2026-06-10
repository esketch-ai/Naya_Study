const axios = require('axios');

class ElevenLabsService {
    constructor(apiKey) {
        this.apiKey = apiKey;
        this.baseUrl = 'https://api.elevenlabs.io/v1';
    }
    
    /**
     * Generate speech from text
     */
    async generateSpeech(text, voiceId, settings = {}) {
        const url = `${this.baseUrl}/speech/generate`;
        
        const defaultSettings = {
            stability: 0.4,
            similarity_boost: 0.8,
            style: 0.6,
        };
        
        const finalSettings = { ...defaultSettings, ...settings };
        
        try {
            const response = await axios.post(
                url,
                {
                    text,
                    voice_name: voiceId,
                    model_id: 'eleven_monolingual_v1',
                    ...finalSettings,
                },
                {
                    headers: {
                        'xi-api-key': this.apiKey,
                        'Content-Type': 'application/json',
                    },
                    responseType: 'stream',
                }
            );
            
            // Convert stream to buffer
            const chunks = [];
            response.data.on('data', (chunk) => chunks.push(chunk));
            response.data.on('end', () => Buffer.concat(chunks));
            
            return {
                success: true,
                audioBuffer: response.data,
                duration: Math.ceil(response.headers['content-length'] / 16000), // Approximate in seconds
            };
        } catch (error) {
            console.error('ElevenLabs API error:', error.message);
            
            return {
                success: false,
                error: error.message,
            };
        }
    }
    
    /**
     * Get available voices
     */
    async getVoices() {
        try {
            const response = await axios.get(
                `${this.baseUrl}/voice/voices`,
                {
                    headers: { 'xi-api-key': this.apiKey },
                }
            );
            
            return response.data.voices;
        } catch (error) {
            console.error('Failed to fetch voices:', error.message);
            return [];
        }
    }
    
    /**
     * Get voice by ID
     */
    async getVoice(voiceId) {
        try {
            const response = await axios.get(
                `${this.baseUrl}/voice/${voiceId}`,
                {
                    headers: { 'xi-api-key': this.apiKey },
                }
            );
            
            return response.data;
        } catch (error) {
            console.error(`Failed to fetch voice ${voiceId}:`, error.message);
            return null;
        }
    }
}

module.exports = ElevenLabsService;
