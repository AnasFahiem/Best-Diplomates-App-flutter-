import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
    // Handle CORS
    if (req.method === 'OPTIONS') {
        return new Response('ok', {
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
            }
        })
    }

    try {
        // Get user from JWT
        const authHeader = req.headers.get('Authorization')!
        const supabaseClient = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_ANON_KEY') ?? '',
            { global: { headers: { Authorization: authHeader } } }
        )

        const { data: { user }, error: userError } = await supabaseClient.auth.getUser()
        if (userError || !user) {
            return new Response(JSON.stringify({ error: 'Unauthorized' }), {
                status: 401,
                headers: { 'Content-Type': 'application/json' }
            })
        }

        // Parse form data
        const formData = await req.formData()
        const file = formData.get('file') as File
        if (!file) {
            return new Response(JSON.stringify({ error: 'No file provided' }), {
                status: 400,
                headers: { 'Content-Type': 'application/json' }
            })
        }

        // Create admin client with service role
        const supabaseAdmin = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
        )

        // Upload to storage
        const fileExt = file.name.split('.').pop()
        const filePath = `${user.id}/avatar.${fileExt}`
        const fileBytes = await file.arrayBuffer()

        const { error: uploadError } = await supabaseAdmin.storage
            .from('avatars')
            .upload(filePath, fileBytes, { upsert: true })

        if (uploadError) {
            throw uploadError
        }

        // Get public URL
        const { data: { publicUrl } } = supabaseAdmin.storage
            .from('avatars')
            .getPublicUrl(filePath)

        const avatarUrl = `${publicUrl}?t=${Date.now()}`

        // Update database with admin permissions (bypasses RLS)
        const { error: dbError } = await supabaseAdmin
            .from('profiles')
            .upsert({
                id: user.id,
                avatar_url: avatarUrl,
                updated_at: new Date().toISOString()
            })

        if (dbError) {
            throw dbError
        }

        return new Response(
            JSON.stringify({ avatarUrl }),
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                }
            }
        )
    } catch (error) {
        return new Response(
            JSON.stringify({ error: error.message }),
            {
                status: 500,
                headers: { 'Content-Type': 'application/json' }
            }
        )
    }
})
