open Lwt

module CU = Cohttp_lwt_unix
module CB = Cohttp_lwt_body

let base_uri = "https://api.bitfinex.com/v1/"
let mk_uri section = Uri.of_string @@ base_uri ^ section

(* GET / unauthentified *)

let get endpoint params type_of_string =
  let uri = mk_uri endpoint in
  CU.Client.get Uri.(with_query' uri params) >>= fun (resp, body) ->
  CB.to_string body >>= fun s ->
  try
    type_of_string s |> function | `Ok r -> return r
                                 | `Error reason -> fail @@ Failure reason
  with exn -> fail exn

module type JSONABLE = sig
  type t
  val to_yojson : t -> Yojson.Safe.json
  val of_yojson : Yojson.Safe.json -> [`Ok of t | `Error of string]
end

module Stringable = struct
  module Of_jsonable (T: JSONABLE) = struct
    let to_string t = T.to_yojson t |> Yojson.Safe.to_string
    let pp ppf t = Format.fprintf ppf "%s" (to_string t)
    let of_string s = Yojson.Safe.from_string s |> T.of_yojson
    let ts_of_string s =
      let ts = Yojson.Safe.from_string s in
      try
        match ts with
        | `List ts ->
            begin
              try
                let ts = List.map
                    (fun t -> match T.of_yojson t with
                       | `Ok a -> a
                       | `Error s -> failwith s) ts
                in `Ok ts
              with Failure s -> `Error s
            end
        | _ -> `Error "Not a json array."
      with exn -> `Error (Printexc.to_string exn)
  end
end

module Ticker = struct
  module Raw = struct
    module T = struct
      type t = {
        mid: string;
        bid: string;
        ask: string;
        last_price: string;
        low: string;
        high: string;
        volume: string;
        timestamp: string;
      } [@@deriving yojson]
    end
    include T
    include Stringable.Of_jsonable(T)

    let ticker pair = get ("pubticker/" ^ pair) [] of_string
  end

  type t = {
    mid: float [@default 0.];
    bid: float [@default 0.];
    ask: float [@default 0.];
    last_price: float [@default 0.];
    low: float [@default 0.];
    high: float [@default 0.];
    volume: float [@default 0.];
    timestamp: float [@default 0.];
  } [@@deriving show,create]

  let of_raw r =
    {
      mid = float_of_string r.Raw.mid;
      bid = float_of_string r.Raw.bid;
      ask = float_of_string r.Raw.ask;
      last_price = float_of_string r.Raw.last_price;
      low = float_of_string r.Raw.low;
      high = float_of_string r.Raw.high;
      volume = float_of_string r.Raw.volume;
      timestamp = float_of_string r.Raw.timestamp;
    }
  let ticker pair = Raw.ticker pair >|= of_raw
end

