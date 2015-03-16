module Ticker :
  sig
    type t = {
      mid : float [@default 0.];
      bid : float [@default 0.];
      ask : float [@default 0.];
      last_price : float [@default 0.];
      low : float [@default 0.];
      high : float [@default 0.];
      volume : float [@default 0.];
      timestamp : float [@default 0.];
    } [@@deriving show,create]

    val ticker : string -> t Lwt.t
    (** [ticker currency_pair] returns the ticker for the given
        [currency_pair]. *)
  end
