
# gui.jl — Built-in HTTP server and Web GUI for Chatting & Training.
# Zero external packages; uses standard library Sockets and json_util.jl.

using Sockets

# (bundled) json_util.jl already included above — include removed for flat layout

function _url_decode(s::AbstractString)
    s = replace(s, "+" => " ")
    out = IOBuffer()
    i = 1
    len = lastindex(s)
    while i <= len
        c = s[i]
        if c == '%' && i + 2 <= len
            hex_str = s[i+1:i+2]
            try
                b = parse(UInt8, hex_str; base=16)
                write(out, b)
                i += 3
                continue
            catch
            end
        end
        write(out, c)
        i = nextind(s, i)
    end
    return String(take!(out))
end

function _parse_query_params(query_str::AbstractString)
    params = Dict{String, String}()
    isempty(query_str) && return params
    for pair in split(query_str, "&")
        parts = split(pair, "="; limit=2)
        if length(parts) == 2
            params[_url_decode(parts[1])] = _url_decode(parts[2])
        elseif length(parts) == 1
            params[_url_decode(parts[1])] = ""
        end
    end
    return params
end

function _format_trace_step(e::ReasoningEvent)
    buf = IOBuffer()
    print(buf, string(e.kind))
    attrs = String[]
    for (k, v) in e.attributes
        push!(attrs, "$k=$v")
    end
    if !isempty(attrs)
        print(buf, " (", join(attrs, ", "), ")")
    end
    return String(take!(buf))
end

"""Start the built-in Web GUI server serving the 2-page Chatting & Training dashboard."""
function start_gui_server(initial_agent::CognitiveAgent=cognitive_agent(:small); port::Int=8080, open_browser::Bool=true)
    ai_ref = Ref{CognitiveAgent}(initial_agent)

    # Listen on IPv4 localhost with fallback port hunting
    local server = nothing
    local actual_port = port
    for p in port:(port + 15)
        try
            server = listen(IPv4(127, 0, 0, 1), p)
            actual_port = p
            break
        catch
            # Try next port
        end
    end

    if server === nothing
        error("Could not bind GUI server on any port between $port and $(port + 15)")
    end

    html_path = joinpath(@__DIR__, "index.html")
    html_content = isfile(html_path) ? read(html_path, String) : EMBEDDED_INDEX_HTML

    url = "http://127.0.0.1:$actual_port"
    println("="^68)
    println("   🧠 TERNARY COGNITIVE AI — WEB DASHBOARD RUNNING")
    println("   URL: $url")
    println("   Features: 💬 Chatting Tab  |  🎓 Training Tab")
    println("   Press Ctrl+C in this console to stop the server.")
    println("="^68)

    if open_browser
        try
            run(`cmd.exe /c start $url`)
        catch
        end
    end

    @async try
        while isopen(server)
            client = accept(server)
            @async try
                _handle_client(client, ai_ref, html_content)
            catch
            finally
                close(client)
            end
        end
    catch e
        if !(e isa Base.IOError)
            @warn "GUI server loop error: $e"
        end
    end

    return server, actual_port
end

function _send_response(io::IO, status_code::Int, content_type::String, body::Union{String, Vector{UInt8}})
    bytes = body isa String ? codeunits(body) : body
    status_text = status_code == 200 ? "OK" : status_code == 404 ? "Not Found" : "Internal Server Error"
    write(io, "HTTP/1.1 $status_code $status_text\r\n")
    write(io, "Content-Type: $content_type\r\n")
    write(io, "Content-Length: $(length(bytes))\r\n")
    write(io, "Access-Control-Allow-Origin: *\r\n")
    write(io, "Access-Control-Allow-Methods: GET, POST, OPTIONS\r\n")
    write(io, "Access-Control-Allow-Headers: Content-Type\r\n")
    write(io, "Connection: close\r\n")
    write(io, "\r\n")
    write(io, bytes)
    flush(io)
end

function _handle_client(io::IO, ai_ref::Ref{CognitiveAgent}, html_content::String)
    line = readline(io)
    isempty(line) && return
    parts = split(line)
    length(parts) >= 2 || return
    method = parts[1]
    raw_uri = parts[2]

    # Preflight OPTIONS
    if method == "OPTIONS"
        _send_response(io, 200, "text/plain", "")
        return
    end

    # Read Headers
    headers = Dict{String, String}()
    while true
        hline = readline(io)
        (isempty(hline) || hline == "\r") && break
        hparts = split(hline, ":"; limit=2)
        if length(hparts) == 2
            headers[lowercase(strip(hparts[1]))] = strip(hparts[2])
        end
    end

    # Read Body if present
    content_len = parse(Int, get(headers, "content-length", "0"))
    body_str = ""
    if content_len > 0
        body_bytes = read(io, content_len)
        body_str = String(body_bytes)
    end

    # Route request
    uri_parts = split(raw_uri, "?"; limit=2)
    path = uri_parts[1]
    query_str = length(uri_parts) > 1 ? uri_parts[2] : ""
    params = _parse_query_params(query_str)

    ai = ai_ref[]

    if method == "GET" && path == "/"
        _send_response(io, 200, "text/html; charset=utf-8", html_content)

    elseif method == "GET" && path == "/api/status"
        m = ai.metrics
        d = ternary_distribution(ai.network)
        data = Dict(
            "scale" => string(ai.config.scale),
            "concepts" => concept_count(ai),
            "synapses" => Dict("positive" => d.positive, "zero" => d.zero, "negative" => d.negative, "total" => d.total),
            "metrics" => Dict(
                "episodes" => m.episodes,
                "total_reward" => m.total_reward,
                "total_punishment" => m.total_punishment,
                "self_corrections" => m.self_corrections,
                "novelty" => m.novel_recombinations,
                "contradictions" => m.contradictions_detected,
                "rejected" => m.hypotheses_rejected
            )
        )
        _send_response(io, 200, "application/json", to_json(data))

    elseif method == "POST" && path == "/api/chat"
        req = from_json(body_str)
        inp = string(get(req, "input", ""))
        expected = haskey(req, "expected") && !isempty(req["expected"]) ? string(req["expected"]) : nothing

        (result, state) = respond!(ai, inp; expected_output=expected)
        output, evaluation, ep = result

        trace_steps = String[_format_trace_step(e) for e in state.trace.events]
        has_contra = !isempty(state.contradictions)

        resp = Dict(
            "output" => output,
            "quality" => string(evaluation.quality),
            "confidence" => state.confidence,
            "reward" => evaluation.reward,
            "punishment" => evaluation.punishment,
            "synaptic_changes" => length(ep.synaptic_changes),
            "contradiction" => has_contra,
            "trace" => trace_steps
        )
        _send_response(io, 200, "application/json", to_json(resp))

    elseif method == "POST" && path == "/api/teach"
        req = from_json(body_str)
        inp = string(get(req, "input", ""))
        exp = string(get(req, "expected", ""))
        (result, state) = respond!(ai, inp; expected_output=exp)
        output, evaluation, ep = result
        resp = Dict("output" => output, "quality" => string(evaluation.quality), "reward" => evaluation.reward, "punishment" => evaluation.punishment)
        _send_response(io, 200, "application/json", to_json(resp))

    elseif method == "GET" && path == "/api/dataset"
        dname = get(params, "name", "data/train.txt")
        # Sanitize relative path
        norm_path = normpath(joinpath(@__DIR__, dname))
        content = isfile(norm_path) ? read(norm_path, String) : get(EMBEDDED_DATASETS, dname, get(EMBEDDED_DATASETS, basename(dname), ""))
        resp = Dict("name" => dname, "content" => content)
        _send_response(io, 200, "application/json", to_json(resp))

    elseif method == "POST" && path == "/api/train"
        req = from_json(body_str)
        text = string(get(req, "text", ""))
        epochs = parse(Int, string(get(req, "epochs", "1")))

        lines = split(text, "\n")
        examples = TrainingExample[]
        for (i, l) in enumerate(lines)
            ex = parse_training_line(String(l), i)
            ex !== nothing && push!(examples, ex)
        end

        log_buf = IOBuffer()
        println(log_buf, "Parsed $(length(examples)) training examples.")
        report = train!(ai, examples; epochs=epochs, verbose=true, io=log_buf)
        logs = String(take!(log_buf))

        resp = Dict(
            "success" => true,
            "logs" => logs,
            "episodes" => report.episodes,
            "total_reward" => report.total_reward,
            "total_punishment" => report.total_punishment
        )
        _send_response(io, 200, "application/json", to_json(resp))

    elseif method == "POST" && path == "/api/reset"
        req = isempty(body_str) ? Dict() : from_json(body_str)
        scale = Symbol(get(req, "scale", "small"))
        ai_ref[] = cognitive_agent(scale)
        _send_response(io, 200, "application/json", to_json(Dict("success" => true, "scale" => string(scale))))

    elseif method == "POST" && path == "/api/save"
        req = from_json(body_str)
        save_path = normpath(joinpath(@__DIR__, get(req, "path", "model.bin")))
        save_model(ai, String(save_path))
        _send_response(io, 200, "application/json", to_json(Dict("success" => true, "message" => "Model saved to $save_path")))

    elseif method == "POST" && path == "/api/load"
        req = from_json(body_str)
        load_path = normpath(joinpath(@__DIR__, get(req, "path", "model.bin")))
        if isfile(load_path)
            ai_ref[] = load_model(String(load_path))
            _send_response(io, 200, "application/json", to_json(Dict("success" => true, "message" => "Model loaded from $load_path")))
        else
            _send_response(io, 404, "application/json", to_json(Dict("success" => false, "message" => "File not found: $load_path")))
        end

    elseif method == "GET" && path == "/api/concepts"
        concepts_list = Any[]
        for (id, c) in sort(collect(ai.semantic.concepts); by=first)
            push!(concepts_list, Dict(
                "id" => id,
                "name" => c.name,
                "reliability" => Float64(concept_reliability(c)),
                "successes" => c.successes,
                "failures" => c.failures,
                "frequency" => c.frequency
            ))
        end
        _send_response(io, 200, "application/json", to_json(concepts_list))

    elseif method == "GET" && path == "/api/relations"
        rels_list = Any[]
        for r in ai.semantic.relations
            push!(rels_list, Dict(
                "subject" => concept_name(ai, r.subject),
                "predicate" => string(r.predicate),
                "object" => concept_name(ai, r.object),
                "provenance" => string(r.provenance)
            ))
        end
        _send_response(io, 200, "application/json", to_json(rels_list))

    else
        _send_response(io, 404, "text/plain", "Not Found: $path")
    end
end

"""Run the Web GUI server and block until interrupted (e.g. via Ctrl+C)."""
function run_gui(; port::Int=8080, open_browser::Bool=true, scale::Symbol=:small, load_path::Union{Nothing,String}=nothing)
    ai = load_path !== nothing && isfile(load_path) ? load_model(load_path) : cognitive_agent(scale)
    server, actual_port = start_gui_server(ai; port=port, open_browser=open_browser)
    try
        while isopen(server)
            sleep(0.5)
        end
    catch e
        if e isa InterruptException
            println("\n[Shutdown] Stopping GUI server...")
            close(server)
        else
            rethrow(e)
        end
    end
    return 0
end

