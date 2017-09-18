{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- $id   := default "0" .Values.uniqueStackId -}}
{{- printf "%s-%s-%s" .Release.Name $id $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default selector stanza that gets used everywhere.
One change and it affects all pieces, no more missed edits when changing.
*/}}
{{- define "default_selector" }}
app: {{ template "name" .}}-{{ default "0" .Values.uniqueStackId }}
release: {{ .Release.Name }}
{{- end -}}
