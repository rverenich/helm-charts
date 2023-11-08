{{- define "shepherd.name" -}}
{{- default "shepherd-collector" .Values.shepherd.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "shepherd.http_scheme"}}
{{- if and .Values.shepherd.config.ingestor.TLSCertFile .Values.shepherd.config.ingestor.TLSKeyFile }}
{{- printf "%s" "https" -}}
{{- else}}
{{- printf "%s" "http" -}}
{{- end }}
{{- end -}}

{{- define "shepherd.grpc" -}}
{{- index .Values "shepherd" "overrideGrpcURL" | default ( printf "%s:%d"  ( include "shepherd.name" . ) ( .Values.shepherd.service.grpcPort | int ) ) -}}
{{- end -}}

{{- define "shepherd.http" -}}
{{- index .Values "shepherd" "overrideHttpURL" | default ( printf "%s://%s:%d" ( include "shepherd.http_scheme" . ) ( include "shepherd.name" . ) ( .Values.shepherd.service.httpPort | int ) ) -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "shepherd.ingress.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "networking.k8s.io/v1") -}}
      {{- print "networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
    {{- print "networking.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Return if ingress is stable.
*/}}
{{- define "shepherd.ingress.isStable" -}}
  {{- eq (include "shepherd.ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return if ingress supports ingressClassName.
*/}}
{{- define "shepherd.ingress.supportsIngressClassName" -}}
  {{- or (eq (include "shepherd.ingress.isStable" .) "true") (and (eq (include "shepherd.ingress.apiVersion" .) "networking.k8s.io/v1beta1")) -}}
{{- end -}}

{{/*
Return if ingress supports pathType.
*/}}
{{- define "shepherd.ingress.supportsPathType" -}}
  {{- or (eq (include "shepherd.ingress.isStable" .) "true") (and (eq (include "shepherd.ingress.apiVersion" .) "networking.k8s.io/v1beta1")) -}}
{{- end -}}

{{- define "shepherd.tls_enabled"}}
{{- if and .Values.shepherd.config.ingestor.TLSCertFile .Values.shepherd.config.ingestor.TLSKeyFile }}
{{- true -}}
{{- else}}
{{- false -}}
{{- end }}
{{- end -}}