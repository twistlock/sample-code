{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "twistlock-console.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Create imageTag version from the version value.
*/}}
{{- define "twistlock-console.version" -}}
{{- .Values.version | replace "." "_" -}}
{{- end -}}

{{/*
Create image from the version and accessToken values.
*/}}
{{- define "twistlock-console.image" -}}
{{- if .Values.imageName -}}
{{- .Values.imageName -}}
{{- else -}}
{{- $version := .Values.version | replace "." "_" -}}
{{- "registry-auth.twistlock.com/tw_<token>/twistlock/console:console_<imageTag>" | replace "<token>" .Values.global.accessToken | replace "<imageTag>" $version -}}
{{- end -}}
{{- end -}}