module Ticker :
  sig
    type t = {
      mid : float;
      bid : float;
      ask : float;
      last_price : float;
      low : float;
      high : float;
      volume : float;
      timestamp : float;
    } [@@deriving show]

    val ticker : string -> t Lwt.t
    (** [ticker currency_pair] returns the ticker for the given
        [currency_pair]. *)
  end
