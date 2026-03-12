//
//  SupabaseConflict.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/11/26.
//

import Supabase
import Foundation

struct SupabaseConflict{
    
    static let shared = SupabaseConflict()
    
    private init(){}
    
    let baseURL = "https://bylgkuwbqjqizmkxnhms.supabase.co/storage/v1/object/public"
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://bylgkuwbqjqizmkxnhms.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ5bGdrdXdicWpxaXpta3huaG1zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMyMzIyMjAsImV4cCI6MjA4ODgwODIyMH0.Zj4KMVqFLwd2fZlO6cMbV4nAzdKBP_IBqHJcZG8LTmQ",
        options: SupabaseClientOptions(
            auth: SupabaseClientOptions.AuthOptions(
                emitLocalSessionAsInitialSession: true
            )
        )
    )
}
