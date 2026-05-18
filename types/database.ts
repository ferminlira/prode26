// types/database.ts — generado contra el schema real de Supabase

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string
          display_name: string | null
          avatar_url: string | null
          preferred_locale: string | null
          created_at: string
        }
        Insert: {
          id: string
          display_name?: string | null
          avatar_url?: string | null
          preferred_locale?: string | null
          created_at?: string
        }
        Update: {
          display_name?: string | null
          avatar_url?: string | null
          preferred_locale?: string | null
        }
      }
      groups: {
        Row: {
          id: string
          name: string
          photo_url: string | null
          theme: string | null
          invite_code: string
          created_by: string       // ← no owner_id
          created_at: string
          penalty_text: string | null  // ← agregado vía migración
        }
        Insert: {
          id?: string
          name: string
          photo_url?: string | null
          theme?: string | null
          invite_code: string
          created_by: string
          created_at?: string
          penalty_text?: string | null
        }
        Update: {
          name?: string
          photo_url?: string | null
          theme?: string | null
          penalty_text?: string | null
        }
      }
      group_members: {
        Row: {
          group_id: string
          user_id: string
          role: string
          joined_at: string
          score: number            // ← agregado vía migración
        }
        Insert: {
          group_id: string
          user_id: string
          role?: string
          joined_at?: string
          score?: number
        }
        Update: {
          role?: string
          score?: number
        }
      }
      teams: {
        Row: {
          id: string               // TEXT — usamos código FIFA (MEX, ARG…)
          name_es: string
          name_en: string
          group_letter: string
          flag_emoji: string | null
        }
        Insert: {
          id: string
          name_es: string
          name_en: string
          group_letter: string
          flag_emoji?: string | null
        }
        Update: never
      }
      matches: {
        Row: {
          id: string               // TEXT — 'M01'…'M72'
          stage: string
          group_letter: string | null
          home_team_id: string
          away_team_id: string
          kickoff_at: string
          venue: string
          city: string
          home_score: number | null
          away_score: number | null
          status: string
          created_at: string
        }
        Insert: {
          id: string
          stage: string
          group_letter?: string | null
          home_team_id: string
          away_team_id: string
          kickoff_at: string
          venue: string
          city: string
          home_score?: number | null
          away_score?: number | null
          status?: string
          created_at?: string
        }
        Update: {
          home_score?: number | null
          away_score?: number | null
          status?: string
        }
      }
      predictions: {
        Row: {
          id: string
          user_id: string
          group_id: string
          match_id: string
          predicted_home_score: number
          predicted_away_score: number
          points: number | null
          locked_at: string | null
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          group_id: string
          match_id: string
          predicted_home_score: number
          predicted_away_score: number
          points?: number | null
          locked_at?: string | null
          updated_at?: string
        }
        Update: {
          predicted_home_score?: number
          predicted_away_score?: number
          points?: number | null
          locked_at?: string | null
          updated_at?: string
        }
      }
    }
    Functions: {
      get_group_preview: {
        Args: { p_invite_code: string }
        Returns: {
          group_id: string
          group_name: string
          member_count: number
          penalty_text: string | null
        }[]
      }
    }
  }
}

export type Profile     = Database['public']['Tables']['profiles']['Row']
export type Group       = Database['public']['Tables']['groups']['Row']
export type GroupMember = Database['public']['Tables']['group_members']['Row']
export type Team        = Database['public']['Tables']['teams']['Row']
export type Match       = Database['public']['Tables']['matches']['Row']
export type Prediction  = Database['public']['Tables']['predictions']['Row']

export type MatchWithTeams = Match & {
  home_team: Pick<Team, 'id' | 'name_es' | 'flag_emoji'>
  away_team: Pick<Team, 'id' | 'name_es' | 'flag_emoji'>
}
