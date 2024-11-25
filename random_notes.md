## Preferred: Generate dashboard and widget contexts (this will generate all main queries boilerplate)
mix phx.gen.context Dashboards Dashboard dashboards title:string
mix phx.gen.context Dashboards Widget widgets title value y:integer x:integer width:integer height:integer type properties options dashboard_id:references:dashboards

## Generate dashboard and widget tables only (without query boilerplate)
mix phx.gen.schema Dashboard.Dashboard dashboards title:string
mix phx.gen.schema Dashboard.Widget widgets title value y:integer x:integer width:integer height:integer type properties options dashboard_id:references:dashboards


