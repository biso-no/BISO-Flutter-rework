// Fixed Appwrite function for fetching jobs
// This should replace your current fetch_jobs function

import { Client, Databases } from "node-appwrite";

export default async function ({ req, res, log, error }) {
    try {
        // Parse request body
        const body = typeof req.body === 'string' ? JSON.parse(req.body) : req.body;
        const { campusId } = body;
        
        log(`Received request for campus ID: ${campusId}`);
        
        // Now properly fetch campus from Appwrite database
        const client = new Client()
            .setEndpoint('https://appwrite.biso.no/v1')
            .setProject('biso')
            .setKey(req.headers['x-appwrite-key']);
        
        const databases = new Databases(client);
        
        // Get campus document using the correct Appwrite ID
        let campusName = 'Oslo'; // Default fallback
        if (campusId && process.env.DATABASE_ID && process.env.COLLECTION_ID) {
            try {
                const campus = await databases.getDocument(
                    process.env.DATABASE_ID,
                    process.env.COLLECTION_ID,
                    campusId
                );
                campusName = campus.name;
                log(`Found campus: ${campusName} (ID: ${campusId})`);
            } catch (campusError) {
                log(`Campus fetch error: ${campusError.message}`);
                // Use static mapping as fallback for hardcoded IDs
                const staticMapping = {
                    'oslo': 'Oslo',
                    'bergen': 'Bergen', 
                    'trondheim': 'Trondheim',
                    'stavanger': 'Stavanger'
                };
                campusName = staticMapping[campusId] || 'Oslo';
            }
        }
        
        log(`Fetching jobs for campus: ${campusName} (ID: ${campusId})`);
        
        // Use fetch to call WordPress API directly
        let jobsData = [];
        try {
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 5000);
            
            const response = await fetch(
                `https://biso.no/wp-json/custom/v1/jobs/?includeExpired=false&per_page=5&campus=${campusName}`,
                { signal: controller.signal }
            );
            
            clearTimeout(timeoutId);
            
            if (response.ok) {
                const rawJobs = await response.json();
                log(`Successfully fetched ${rawJobs.length} jobs from WordPress`);
                
                // Clean and transform the WordPress data
                jobsData = rawJobs.map(job => ({
                    id: job.id?.toString() || '',
                    title: cleanHtmlEntities(job.title || ''),
                    description: cleanWordPressContent(job.content || ''),
                    department: Array.isArray(job.type) && job.type.length > 0 ? cleanHtmlEntities(job.type[0]) : 'BISO',
                    requirements: Array.isArray(job.interests) ? job.interests.map(cleanHtmlEntities) : [],
                    skills: Array.isArray(job.type) ? job.type.map(cleanHtmlEntities) : [],
                    expiry_date: job.expiry_date || '',
                    url: job.url || '',
                    campus: Array.isArray(job.campus) ? job.campus.map(cleanHtmlEntities) : [],
                    originalContent: job.content // Keep original for reference
                }));
                
                log(`Processed ${jobsData.length} jobs with cleaned content`);
            } else {
                log(`WordPress API error: ${response.status} ${response.statusText}`);
            }
        } catch (fetchError) {
            log("Fetch error:", fetchError);
        }

        // Helper functions for cleaning WordPress content
        function cleanHtmlEntities(text) {
            if (!text) return '';
            return text
                .replace(/&amp;/g, '&')
                .replace(/&lt;/g, '<')
                .replace(/&gt;/g, '>')
                .replace(/&quot;/g, '"')
                .replace(/&#39;/g, "'")
                .replace(/&nbsp;/g, ' ');
        }

        function cleanWordPressContent(content) {
            if (!content) return '';
            
            // Remove WordPress block comments
            let cleaned = content.replace(/<!-- wp:[^>]*-->/g, '');
            cleaned = cleaned.replace(/<!-- \/wp:[^>]*-->/g, '');
            
            // Remove HTML tags but preserve line breaks
            cleaned = cleaned.replace(/<\/p>/g, '\n');
            cleaned = cleaned.replace(/<br\s*\/?>/gi, '\n');
            cleaned = cleaned.replace(/<[^>]*>/g, '');
            
            // Clean up HTML entities
            cleaned = cleanHtmlEntities(cleaned);
            
            // Clean up whitespace
            cleaned = cleaned.replace(/\n\s*\n/g, '\n\n'); // Multiple line breaks to double
            cleaned = cleaned.replace(/^\s+|\s+$/g, ''); // Trim
            cleaned = cleaned.replace(/\s+/g, ' '); // Multiple spaces to single
            
            return cleaned;
        }
        
        return res.json({
            jobs: jobsData,
            campusName: campusName,
            timestamp: new Date().toISOString()
        });
    } catch (e) {
        error("Function error:", e);
        return res.json({ 
            error: "Error in function execution", 
            message: e instanceof Error ? e.message : String(e),
            timestamp: new Date().toISOString()
        });
    }
}