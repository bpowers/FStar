open Prims
let _z3hash_checked: Prims.bool FStar_ST.ref = FStar_Util.mk_ref false
let _z3hash_expected: Prims.string = "1f29cebd4df6"
let _z3url: Prims.string =
  "https://github.com/FStarLang/binaries/tree/master/z3-tested"
let parse_z3_version_lines:
  Prims.string -> Prims.string FStar_Pervasives_Native.option =
  fun out  ->
    match FStar_Util.splitlines out with
    | x::uu____18 ->
        let trimmed = FStar_Util.trim_string x in
        let parts = FStar_Util.split trimmed " " in
        let rec aux uu___81_32 =
          match uu___81_32 with
          | hash::[] ->
              let n1 =
                Prims.min (FStar_String.strlen _z3hash_expected)
                  (FStar_String.strlen hash) in
              let hash_prefix =
                FStar_String.substring hash (Prims.parse_int "0") n1 in
              if hash_prefix = _z3hash_expected
              then
                ((let uu____43 = FStar_Options.debug_any () in
                  if uu____43
                  then
                    let msg =
                      FStar_Util.format1
                        "Successfully found expected Z3 commit hash %s\n"
                        hash in
                    FStar_Util.print_string msg
                  else ());
                 FStar_Pervasives_Native.None)
              else
                (let msg =
                   FStar_Util.format2
                     "Expected Z3 commit hash \"%s\", got \"%s\""
                     _z3hash_expected trimmed in
                 FStar_Pervasives_Native.Some msg)
          | uu____48::q -> aux q
          | uu____52 ->
              FStar_Pervasives_Native.Some "No Z3 commit hash found" in
        aux parts
    | uu____55 -> FStar_Pervasives_Native.Some "No Z3 version string found"
let z3hash_warning_message:
  Prims.unit ->
    (FStar_Errors.issue_level,Prims.string) FStar_Pervasives_Native.tuple2
      FStar_Pervasives_Native.option
  =
  fun uu____66  ->
    let run_proc_result =
      try
        let uu____95 =
          let uu____102 = FStar_Options.z3_exe () in
          FStar_Util.run_proc uu____102 "-version" "" in
        FStar_Pervasives_Native.Some uu____95
      with | uu____120 -> FStar_Pervasives_Native.None in
    match run_proc_result with
    | FStar_Pervasives_Native.None  ->
        FStar_Pervasives_Native.Some
          (FStar_Errors.EError, "Could not run Z3")
    | FStar_Pervasives_Native.Some (uu____143,out,uu____145) ->
        let uu____152 = parse_z3_version_lines out in
        (match uu____152 with
         | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
         | FStar_Pervasives_Native.Some msg ->
             FStar_Pervasives_Native.Some (FStar_Errors.EWarning, msg))
let check_z3hash: Prims.unit -> Prims.unit =
  fun uu____172  ->
    let uu____173 =
      let uu____174 = FStar_ST.op_Bang _z3hash_checked in
      Prims.op_Negation uu____174 in
    if uu____173
    then
      (FStar_ST.op_Colon_Equals _z3hash_checked true;
       (let uu____272 = z3hash_warning_message () in
        match uu____272 with
        | FStar_Pervasives_Native.None  -> ()
        | FStar_Pervasives_Native.Some (level,msg) ->
            let msg1 =
              FStar_Util.format4 "%s\n%s\n%s\n%s\n" msg
                "Please download the version of Z3 corresponding to your platform from:"
                _z3url "and add the bin/ subdirectory into your PATH" in
            FStar_Errors.add_one
              (FStar_Errors.mk_issue level FStar_Pervasives_Native.None msg1)))
    else ()
let ini_params: Prims.unit -> Prims.string =
  fun uu____293  ->
    check_z3hash ();
    (let uu____295 =
       let uu____298 =
         let uu____301 =
           let uu____304 =
             let uu____305 =
               let uu____306 = FStar_Options.z3_seed () in
               FStar_Util.string_of_int uu____306 in
             FStar_Util.format1 "smt.random_seed=%s" uu____305 in
           [uu____304] in
         "-smt2 -in auto_config=false model=true smt.relevancy=2" ::
           uu____301 in
       let uu____307 = FStar_Options.z3_cliopt () in
       FStar_List.append uu____298 uu____307 in
     FStar_String.concat " " uu____295)
type label = Prims.string[@@deriving show]
type unsat_core = Prims.string Prims.list FStar_Pervasives_Native.option
[@@deriving show]
type z3status =
  | UNSAT of unsat_core
  | SAT of
  (FStar_SMTEncoding_Term.error_labels,Prims.string
                                         FStar_Pervasives_Native.option)
  FStar_Pervasives_Native.tuple2
  | UNKNOWN of
  (FStar_SMTEncoding_Term.error_labels,Prims.string
                                         FStar_Pervasives_Native.option)
  FStar_Pervasives_Native.tuple2
  | TIMEOUT of
  (FStar_SMTEncoding_Term.error_labels,Prims.string
                                         FStar_Pervasives_Native.option)
  FStar_Pervasives_Native.tuple2
  | KILLED[@@deriving show]
let uu___is_UNSAT: z3status -> Prims.bool =
  fun projectee  ->
    match projectee with | UNSAT _0 -> true | uu____352 -> false
let __proj__UNSAT__item___0: z3status -> unsat_core =
  fun projectee  -> match projectee with | UNSAT _0 -> _0
let uu___is_SAT: z3status -> Prims.bool =
  fun projectee  ->
    match projectee with | SAT _0 -> true | uu____370 -> false
let __proj__SAT__item___0:
  z3status ->
    (FStar_SMTEncoding_Term.error_labels,Prims.string
                                           FStar_Pervasives_Native.option)
      FStar_Pervasives_Native.tuple2
  = fun projectee  -> match projectee with | SAT _0 -> _0
let uu___is_UNKNOWN: z3status -> Prims.bool =
  fun projectee  ->
    match projectee with | UNKNOWN _0 -> true | uu____406 -> false
let __proj__UNKNOWN__item___0:
  z3status ->
    (FStar_SMTEncoding_Term.error_labels,Prims.string
                                           FStar_Pervasives_Native.option)
      FStar_Pervasives_Native.tuple2
  = fun projectee  -> match projectee with | UNKNOWN _0 -> _0
let uu___is_TIMEOUT: z3status -> Prims.bool =
  fun projectee  ->
    match projectee with | TIMEOUT _0 -> true | uu____442 -> false
let __proj__TIMEOUT__item___0:
  z3status ->
    (FStar_SMTEncoding_Term.error_labels,Prims.string
                                           FStar_Pervasives_Native.option)
      FStar_Pervasives_Native.tuple2
  = fun projectee  -> match projectee with | TIMEOUT _0 -> _0
let uu___is_KILLED: z3status -> Prims.bool =
  fun projectee  ->
    match projectee with | KILLED  -> true | uu____471 -> false
type z3statistics = Prims.string FStar_Util.smap[@@deriving show]
let status_tag: z3status -> Prims.string =
  fun uu___82_476  ->
    match uu___82_476 with
    | SAT uu____477 -> "sat"
    | UNSAT uu____484 -> "unsat"
    | UNKNOWN uu____485 -> "unknown"
    | TIMEOUT uu____492 -> "timeout"
    | KILLED  -> "killed"
let status_string_and_errors:
  z3status ->
    (Prims.string,FStar_SMTEncoding_Term.error_labels)
      FStar_Pervasives_Native.tuple2
  =
  fun s  ->
    match s with
    | KILLED  -> ((status_tag s), [])
    | UNSAT uu____512 -> ((status_tag s), [])
    | SAT (errs,msg) ->
        let uu____521 =
          FStar_Util.format2 "%s%s" (status_tag s)
            (match msg with
             | FStar_Pervasives_Native.None  -> ""
             | FStar_Pervasives_Native.Some msg1 ->
                 Prims.strcat " because " msg1) in
        (uu____521, errs)
    | UNKNOWN (errs,msg) ->
        let uu____529 =
          FStar_Util.format2 "%s%s" (status_tag s)
            (match msg with
             | FStar_Pervasives_Native.None  -> ""
             | FStar_Pervasives_Native.Some msg1 ->
                 Prims.strcat " because " msg1) in
        (uu____529, errs)
    | TIMEOUT (errs,msg) ->
        let uu____537 =
          FStar_Util.format2 "%s%s" (status_tag s)
            (match msg with
             | FStar_Pervasives_Native.None  -> ""
             | FStar_Pervasives_Native.Some msg1 ->
                 Prims.strcat " because " msg1) in
        (uu____537, errs)
let tid: Prims.unit -> Prims.string =
  fun uu____541  ->
    let uu____542 = FStar_Util.current_tid () in
    FStar_All.pipe_right uu____542 FStar_Util.string_of_int
let new_z3proc: Prims.string -> FStar_Util.proc =
  fun id1  ->
    let cond pid s = let x = (FStar_Util.trim_string s) = "Done!" in x in
    let uu____554 = FStar_Options.z3_exe () in
    let uu____555 = ini_params () in
    FStar_Util.start_process false id1 uu____554 uu____555 cond
type bgproc =
  {
  grab: Prims.unit -> FStar_Util.proc;
  release: Prims.unit -> Prims.unit;
  refresh: Prims.unit -> Prims.unit;
  restart: Prims.unit -> Prims.unit;}[@@deriving show]
let __proj__Mkbgproc__item__grab: bgproc -> Prims.unit -> FStar_Util.proc =
  fun projectee  ->
    match projectee with
    | { grab = __fname__grab; release = __fname__release;
        refresh = __fname__refresh; restart = __fname__restart;_} ->
        __fname__grab
let __proj__Mkbgproc__item__release: bgproc -> Prims.unit -> Prims.unit =
  fun projectee  ->
    match projectee with
    | { grab = __fname__grab; release = __fname__release;
        refresh = __fname__refresh; restart = __fname__restart;_} ->
        __fname__release
let __proj__Mkbgproc__item__refresh: bgproc -> Prims.unit -> Prims.unit =
  fun projectee  ->
    match projectee with
    | { grab = __fname__grab; release = __fname__release;
        refresh = __fname__refresh; restart = __fname__restart;_} ->
        __fname__refresh
let __proj__Mkbgproc__item__restart: bgproc -> Prims.unit -> Prims.unit =
  fun projectee  ->
    match projectee with
    | { grab = __fname__grab; release = __fname__release;
        refresh = __fname__refresh; restart = __fname__restart;_} ->
        __fname__restart
type query_log =
  {
  get_module_name: Prims.unit -> Prims.string;
  set_module_name: Prims.string -> Prims.unit;
  write_to_log: Prims.string -> Prims.unit;
  close_log: Prims.unit -> Prims.unit;
  log_file_name: Prims.unit -> Prims.string;}[@@deriving show]
let __proj__Mkquery_log__item__get_module_name:
  query_log -> Prims.unit -> Prims.string =
  fun projectee  ->
    match projectee with
    | { get_module_name = __fname__get_module_name;
        set_module_name = __fname__set_module_name;
        write_to_log = __fname__write_to_log; close_log = __fname__close_log;
        log_file_name = __fname__log_file_name;_} -> __fname__get_module_name
let __proj__Mkquery_log__item__set_module_name:
  query_log -> Prims.string -> Prims.unit =
  fun projectee  ->
    match projectee with
    | { get_module_name = __fname__get_module_name;
        set_module_name = __fname__set_module_name;
        write_to_log = __fname__write_to_log; close_log = __fname__close_log;
        log_file_name = __fname__log_file_name;_} -> __fname__set_module_name
let __proj__Mkquery_log__item__write_to_log:
  query_log -> Prims.string -> Prims.unit =
  fun projectee  ->
    match projectee with
    | { get_module_name = __fname__get_module_name;
        set_module_name = __fname__set_module_name;
        write_to_log = __fname__write_to_log; close_log = __fname__close_log;
        log_file_name = __fname__log_file_name;_} -> __fname__write_to_log
let __proj__Mkquery_log__item__close_log:
  query_log -> Prims.unit -> Prims.unit =
  fun projectee  ->
    match projectee with
    | { get_module_name = __fname__get_module_name;
        set_module_name = __fname__set_module_name;
        write_to_log = __fname__write_to_log; close_log = __fname__close_log;
        log_file_name = __fname__log_file_name;_} -> __fname__close_log
let __proj__Mkquery_log__item__log_file_name:
  query_log -> Prims.unit -> Prims.string =
  fun projectee  ->
    match projectee with
    | { get_module_name = __fname__get_module_name;
        set_module_name = __fname__set_module_name;
        write_to_log = __fname__write_to_log; close_log = __fname__close_log;
        log_file_name = __fname__log_file_name;_} -> __fname__log_file_name
let query_logging: query_log =
  let query_number = FStar_Util.mk_ref (Prims.parse_int "0") in
  let log_file_opt = FStar_Util.mk_ref FStar_Pervasives_Native.None in
  let used_file_names = FStar_Util.mk_ref [] in
  let current_module_name = FStar_Util.mk_ref FStar_Pervasives_Native.None in
  let current_file_name = FStar_Util.mk_ref FStar_Pervasives_Native.None in
  let set_module_name n1 =
    FStar_ST.op_Colon_Equals current_module_name
      (FStar_Pervasives_Native.Some n1) in
  let get_module_name uu____930 =
    let uu____931 = FStar_ST.op_Bang current_module_name in
    match uu____931 with
    | FStar_Pervasives_Native.None  -> failwith "Module name not set"
    | FStar_Pervasives_Native.Some n1 -> n1 in
  let new_log_file uu____1004 =
    let uu____1005 = FStar_ST.op_Bang current_module_name in
    match uu____1005 with
    | FStar_Pervasives_Native.None  -> failwith "current module not set"
    | FStar_Pervasives_Native.Some n1 ->
        let file_name =
          let uu____1076 =
            let uu____1083 = FStar_ST.op_Bang used_file_names in
            FStar_List.tryFind
              (fun uu____1171  ->
                 match uu____1171 with | (m,uu____1177) -> n1 = m) uu____1083 in
          match uu____1076 with
          | FStar_Pervasives_Native.None  ->
              ((let uu____1183 =
                  let uu____1190 = FStar_ST.op_Bang used_file_names in
                  (n1, (Prims.parse_int "0")) :: uu____1190 in
                FStar_ST.op_Colon_Equals used_file_names uu____1183);
               n1)
          | FStar_Pervasives_Native.Some (uu____1349,k) ->
              ((let uu____1356 =
                  let uu____1363 = FStar_ST.op_Bang used_file_names in
                  (n1, (k + (Prims.parse_int "1"))) :: uu____1363 in
                FStar_ST.op_Colon_Equals used_file_names uu____1356);
               (let uu____1522 =
                  FStar_Util.string_of_int (k + (Prims.parse_int "1")) in
                FStar_Util.format2 "%s-%s" n1 uu____1522)) in
        let file_name1 = FStar_Util.format1 "queries-%s.smt2" file_name in
        (FStar_ST.op_Colon_Equals current_file_name
           (FStar_Pervasives_Native.Some file_name1);
         (let fh = FStar_Util.open_file_for_writing file_name1 in
          FStar_ST.op_Colon_Equals log_file_opt
            (FStar_Pervasives_Native.Some fh);
          fh)) in
  let get_log_file uu____1662 =
    let uu____1663 = FStar_ST.op_Bang log_file_opt in
    match uu____1663 with
    | FStar_Pervasives_Native.None  -> new_log_file ()
    | FStar_Pervasives_Native.Some fh -> fh in
  let append_to_log str =
    let uu____1737 = get_log_file () in
    FStar_Util.append_to_file uu____1737 str in
  let write_to_new_log str =
    let dir_name =
      let uu____1743 = FStar_ST.op_Bang current_file_name in
      match uu____1743 with
      | FStar_Pervasives_Native.None  ->
          let dir_name =
            let uu____1813 = FStar_ST.op_Bang current_module_name in
            match uu____1813 with
            | FStar_Pervasives_Native.None  ->
                failwith "current module not set"
            | FStar_Pervasives_Native.Some n1 ->
                FStar_Util.format1 "queries-%s" n1 in
          (FStar_Util.mkdir true dir_name;
           FStar_ST.op_Colon_Equals current_file_name
             (FStar_Pervasives_Native.Some dir_name);
           dir_name)
      | FStar_Pervasives_Native.Some n1 -> n1 in
    let qnum = FStar_ST.op_Bang query_number in
    (let uu____2016 =
       let uu____2017 = FStar_ST.op_Bang query_number in
       uu____2017 + (Prims.parse_int "1") in
     FStar_ST.op_Colon_Equals query_number uu____2016);
    (let file_name =
       let uu____2143 = FStar_Util.string_of_int qnum in
       FStar_Util.format1 "query-%s.smt2" uu____2143 in
     let file_name1 = FStar_Util.concat_dir_filename dir_name file_name in
     FStar_Util.write_file file_name1 str) in
  let write_to_log str =
    let uu____2149 =
      let uu____2150 = FStar_Options.n_cores () in
      uu____2150 > (Prims.parse_int "1") in
    if uu____2149 then write_to_new_log str else append_to_log str in
  let close_log uu____2155 =
    let uu____2156 = FStar_ST.op_Bang log_file_opt in
    match uu____2156 with
    | FStar_Pervasives_Native.None  -> ()
    | FStar_Pervasives_Native.Some fh ->
        (FStar_Util.close_file fh;
         FStar_ST.op_Colon_Equals log_file_opt FStar_Pervasives_Native.None) in
  let log_file_name uu____2296 =
    let uu____2297 = FStar_ST.op_Bang current_file_name in
    match uu____2297 with
    | FStar_Pervasives_Native.None  -> failwith "no log file"
    | FStar_Pervasives_Native.Some n1 -> n1 in
  { get_module_name; set_module_name; write_to_log; close_log; log_file_name
  }
let bg_z3_proc: bgproc =
  let the_z3proc = FStar_Util.mk_ref FStar_Pervasives_Native.None in
  let new_proc =
    let ctr = FStar_Util.mk_ref (- (Prims.parse_int "1")) in
    fun uu____2380  ->
      let uu____2381 =
        let uu____2382 =
          FStar_Util.incr ctr;
          (let uu____2405 = FStar_ST.op_Bang ctr in
           FStar_All.pipe_right uu____2405 FStar_Util.string_of_int) in
        FStar_Util.format1 "bg-%s" uu____2382 in
      new_z3proc uu____2381 in
  let z3proc uu____2471 =
    (let uu____2473 =
       let uu____2474 = FStar_ST.op_Bang the_z3proc in
       uu____2474 = FStar_Pervasives_Native.None in
     if uu____2473
     then
       let uu____2545 =
         let uu____2548 = new_proc () in
         FStar_Pervasives_Native.Some uu____2548 in
       FStar_ST.op_Colon_Equals the_z3proc uu____2545
     else ());
    (let uu____2616 = FStar_ST.op_Bang the_z3proc in
     FStar_Util.must uu____2616) in
  let x = [] in
  let grab uu____2691 = FStar_Util.monitor_enter x; z3proc () in
  let release uu____2698 = FStar_Util.monitor_exit x in
  let refresh uu____2704 =
    let proc = grab () in
    FStar_Util.kill_process proc;
    (let uu____2708 =
       let uu____2711 = new_proc () in
       FStar_Pervasives_Native.Some uu____2711 in
     FStar_ST.op_Colon_Equals the_z3proc uu____2708);
    query_logging.close_log ();
    release () in
  let restart uu____2782 =
    FStar_Util.monitor_enter ();
    query_logging.close_log ();
    FStar_ST.op_Colon_Equals the_z3proc FStar_Pervasives_Native.None;
    (let uu____2853 =
       let uu____2856 = new_proc () in
       FStar_Pervasives_Native.Some uu____2856 in
     FStar_ST.op_Colon_Equals the_z3proc uu____2853);
    FStar_Util.monitor_exit () in
  { grab; release; refresh; restart }
let at_log_file: Prims.unit -> Prims.string =
  fun uu____2925  ->
    let uu____2926 = FStar_Options.log_queries () in
    if uu____2926
    then
      let uu____2927 = query_logging.log_file_name () in
      Prims.strcat "@" uu____2927
    else ""
type smt_output_section = Prims.string Prims.list[@@deriving show]
type smt_output =
  {
  smt_result: smt_output_section;
  smt_reason_unknown: smt_output_section FStar_Pervasives_Native.option;
  smt_unsat_core: smt_output_section FStar_Pervasives_Native.option;
  smt_statistics: smt_output_section FStar_Pervasives_Native.option;
  smt_labels: smt_output_section FStar_Pervasives_Native.option;}[@@deriving
                                                                   show]
let __proj__Mksmt_output__item__smt_result: smt_output -> smt_output_section
  =
  fun projectee  ->
    match projectee with
    | { smt_result = __fname__smt_result;
        smt_reason_unknown = __fname__smt_reason_unknown;
        smt_unsat_core = __fname__smt_unsat_core;
        smt_statistics = __fname__smt_statistics;
        smt_labels = __fname__smt_labels;_} -> __fname__smt_result
let __proj__Mksmt_output__item__smt_reason_unknown:
  smt_output -> smt_output_section FStar_Pervasives_Native.option =
  fun projectee  ->
    match projectee with
    | { smt_result = __fname__smt_result;
        smt_reason_unknown = __fname__smt_reason_unknown;
        smt_unsat_core = __fname__smt_unsat_core;
        smt_statistics = __fname__smt_statistics;
        smt_labels = __fname__smt_labels;_} -> __fname__smt_reason_unknown
let __proj__Mksmt_output__item__smt_unsat_core:
  smt_output -> smt_output_section FStar_Pervasives_Native.option =
  fun projectee  ->
    match projectee with
    | { smt_result = __fname__smt_result;
        smt_reason_unknown = __fname__smt_reason_unknown;
        smt_unsat_core = __fname__smt_unsat_core;
        smt_statistics = __fname__smt_statistics;
        smt_labels = __fname__smt_labels;_} -> __fname__smt_unsat_core
let __proj__Mksmt_output__item__smt_statistics:
  smt_output -> smt_output_section FStar_Pervasives_Native.option =
  fun projectee  ->
    match projectee with
    | { smt_result = __fname__smt_result;
        smt_reason_unknown = __fname__smt_reason_unknown;
        smt_unsat_core = __fname__smt_unsat_core;
        smt_statistics = __fname__smt_statistics;
        smt_labels = __fname__smt_labels;_} -> __fname__smt_statistics
let __proj__Mksmt_output__item__smt_labels:
  smt_output -> smt_output_section FStar_Pervasives_Native.option =
  fun projectee  ->
    match projectee with
    | { smt_result = __fname__smt_result;
        smt_reason_unknown = __fname__smt_reason_unknown;
        smt_unsat_core = __fname__smt_unsat_core;
        smt_statistics = __fname__smt_statistics;
        smt_labels = __fname__smt_labels;_} -> __fname__smt_labels
let smt_output_sections: Prims.string Prims.list -> smt_output =
  fun lines  ->
    let rec until tag lines1 =
      match lines1 with
      | [] -> FStar_Pervasives_Native.None
      | l::lines2 ->
          if tag = l
          then FStar_Pervasives_Native.Some ([], lines2)
          else
            (let uu____3128 = until tag lines2 in
             FStar_Util.map_opt uu____3128
               (fun uu____3158  ->
                  match uu____3158 with
                  | (until_tag,rest) -> ((l :: until_tag), rest))) in
    let start_tag tag = Prims.strcat "<" (Prims.strcat tag ">") in
    let end_tag tag = Prims.strcat "</" (Prims.strcat tag ">") in
    let find_section tag lines1 =
      let uu____3228 = until (start_tag tag) lines1 in
      match uu____3228 with
      | FStar_Pervasives_Native.None  ->
          (FStar_Pervasives_Native.None, lines1)
      | FStar_Pervasives_Native.Some (prefix1,suffix) ->
          let uu____3283 = until (end_tag tag) suffix in
          (match uu____3283 with
           | FStar_Pervasives_Native.None  ->
               failwith
                 (Prims.strcat "Parse error: "
                    (Prims.strcat (end_tag tag) " not found"))
           | FStar_Pervasives_Native.Some (section,suffix1) ->
               ((FStar_Pervasives_Native.Some section),
                 (FStar_List.append prefix1 suffix1))) in
    let uu____3348 = find_section "result" lines in
    match uu____3348 with
    | (result_opt,lines1) ->
        let result = FStar_Util.must result_opt in
        let uu____3378 = find_section "reason-unknown" lines1 in
        (match uu____3378 with
         | (reason_unknown,lines2) ->
             let uu____3403 = find_section "unsat-core" lines2 in
             (match uu____3403 with
              | (unsat_core,lines3) ->
                  let uu____3428 = find_section "statistics" lines3 in
                  (match uu____3428 with
                   | (statistics,lines4) ->
                       let uu____3453 = find_section "labels" lines4 in
                       (match uu____3453 with
                        | (labels,lines5) ->
                            let remaining =
                              let uu____3481 = until "Done!" lines5 in
                              match uu____3481 with
                              | FStar_Pervasives_Native.None  -> lines5
                              | FStar_Pervasives_Native.Some (prefix1,suffix)
                                  -> FStar_List.append prefix1 suffix in
                            ((match remaining with
                              | [] -> ()
                              | uu____3521 ->
                                  let uu____3524 =
                                    let uu____3525 =
                                      query_logging.get_module_name () in
                                    FStar_Util.format2
                                      "%s: Unexpected output from Z3: %s\n"
                                      uu____3525
                                      (FStar_String.concat "\n" remaining) in
                                  FStar_Errors.warn FStar_Range.dummyRange
                                    uu____3524);
                             (let uu____3526 = FStar_Util.must result_opt in
                              {
                                smt_result = uu____3526;
                                smt_reason_unknown = reason_unknown;
                                smt_unsat_core = unsat_core;
                                smt_statistics = statistics;
                                smt_labels = labels
                              }))))))
let doZ3Exe:
  Prims.bool ->
    Prims.string ->
      FStar_SMTEncoding_Term.error_labels ->
        (z3status,z3statistics) FStar_Pervasives_Native.tuple2
  =
  fun fresh  ->
    fun input  ->
      fun label_messages  ->
        let parse z3out =
          let lines =
            FStar_All.pipe_right (FStar_String.split [10] z3out)
              (FStar_List.map FStar_Util.trim_string) in
          let smt_output = smt_output_sections lines in
          let unsat_core =
            match smt_output.smt_unsat_core with
            | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
            | FStar_Pervasives_Native.Some s ->
                let s1 = FStar_Util.trim_string (FStar_String.concat " " s) in
                let s2 =
                  FStar_Util.substring s1 (Prims.parse_int "1")
                    ((FStar_String.length s1) - (Prims.parse_int "2")) in
                if FStar_Util.starts_with s2 "error"
                then FStar_Pervasives_Native.None
                else
                  (let uu____3586 =
                     FStar_All.pipe_right (FStar_Util.split s2 " ")
                       (FStar_Util.sort_with FStar_String.compare) in
                   FStar_Pervasives_Native.Some uu____3586) in
          let labels =
            match smt_output.smt_labels with
            | FStar_Pervasives_Native.None  -> []
            | FStar_Pervasives_Native.Some lines1 ->
                let rec lblnegs lines2 =
                  match lines2 with
                  | lname::"false"::rest when
                      FStar_Util.starts_with lname "label_" ->
                      let uu____3647 = lblnegs rest in lname :: uu____3647
                  | lname::uu____3651::rest when
                      FStar_Util.starts_with lname "label_" -> lblnegs rest
                  | uu____3655 -> [] in
                let lblnegs1 = lblnegs lines1 in
                FStar_All.pipe_right lblnegs1
                  (FStar_List.collect
                     (fun l  ->
                        let uu____3688 =
                          FStar_All.pipe_right label_messages
                            (FStar_List.tryFind
                               (fun uu____3727  ->
                                  match uu____3727 with
                                  | (m,uu____3739,uu____3740) ->
                                      (FStar_Pervasives_Native.fst m) = l)) in
                        match uu____3688 with
                        | FStar_Pervasives_Native.None  -> []
                        | FStar_Pervasives_Native.Some (lbl,msg,r) ->
                            [(lbl, msg, r)])) in
          let statistics =
            let statistics = FStar_Util.smap_create (Prims.parse_int "0") in
            match smt_output.smt_statistics with
            | FStar_Pervasives_Native.None  -> statistics
            | FStar_Pervasives_Native.Some lines1 ->
                let parse_line line =
                  let pline =
                    FStar_Util.split (FStar_Util.trim_string line) ":" in
                  match pline with
                  | "("::entry::[] ->
                      let tokens = FStar_Util.split entry " " in
                      let key = FStar_List.hd tokens in
                      let ltok =
                        FStar_List.nth tokens
                          ((FStar_List.length tokens) - (Prims.parse_int "1")) in
                      let value =
                        if FStar_Util.ends_with ltok ")"
                        then
                          FStar_Util.substring ltok (Prims.parse_int "0")
                            ((FStar_String.length ltok) -
                               (Prims.parse_int "1"))
                        else ltok in
                      FStar_Util.smap_add statistics key value
                  | ""::entry::[] ->
                      let tokens = FStar_Util.split entry " " in
                      let key = FStar_List.hd tokens in
                      let ltok =
                        FStar_List.nth tokens
                          ((FStar_List.length tokens) - (Prims.parse_int "1")) in
                      let value =
                        if FStar_Util.ends_with ltok ")"
                        then
                          FStar_Util.substring ltok (Prims.parse_int "0")
                            ((FStar_String.length ltok) -
                               (Prims.parse_int "1"))
                        else ltok in
                      FStar_Util.smap_add statistics key value
                  | uu____3852 -> () in
                (FStar_List.iter parse_line lines1; statistics) in
          let reason_unknown =
            FStar_Util.map_opt smt_output.smt_reason_unknown
              (fun x  ->
                 let ru = FStar_String.concat " " x in
                 if FStar_Util.starts_with ru "(:reason-unknown \""
                 then
                   let reason =
                     FStar_Util.substring_from ru
                       (FStar_String.length "(:reason-unknown \"") in
                   let res =
                     FStar_String.substring reason (Prims.parse_int "0")
                       ((FStar_String.length reason) - (Prims.parse_int "2")) in
                   res
                 else ru) in
          let status =
            (let uu____3870 = FStar_Options.debug_any () in
             if uu____3870
             then
               let uu____3871 =
                 FStar_Util.format1 "Z3 says: %s\n"
                   (FStar_String.concat "\n" smt_output.smt_result) in
               FStar_All.pipe_left FStar_Util.print_string uu____3871
             else ());
            (match smt_output.smt_result with
             | "unsat"::[] -> UNSAT unsat_core
             | "sat"::[] -> SAT (labels, reason_unknown)
             | "unknown"::[] -> UNKNOWN (labels, reason_unknown)
             | "timeout"::[] -> TIMEOUT (labels, reason_unknown)
             | "killed"::[] -> (bg_z3_proc.restart (); KILLED)
             | uu____3916 ->
                 let uu____3917 =
                   FStar_Util.format1
                     "Unexpected output from Z3: got output result: %s\n"
                     (FStar_String.concat "\n" smt_output.smt_result) in
                 failwith uu____3917) in
          (status, statistics) in
        let cond pid s = let x = (FStar_Util.trim_string s) = "Done!" in x in
        let stdout1 =
          if fresh
          then
            let uu____3927 = tid () in
            let uu____3928 = FStar_Options.z3_exe () in
            let uu____3929 = ini_params () in
            FStar_Util.launch_process false uu____3927 uu____3928 uu____3929
              input cond
          else
            (let proc = bg_z3_proc.grab () in
             let stdout1 = FStar_Util.ask_process proc input in
             bg_z3_proc.release (); stdout1) in
        parse (FStar_Util.trim_string stdout1)
let z3_options: Prims.unit -> Prims.string =
  fun uu____3936  ->
    "(set-option :global-decls false)\n(set-option :smt.mbqi false)\n(set-option :auto_config false)\n(set-option :produce-unsat-cores true)\n"
type 'a job = {
  job: Prims.unit -> 'a;
  callback: 'a -> Prims.unit;}[@@deriving show]
let __proj__Mkjob__item__job: 'a . 'a job -> Prims.unit -> 'a =
  fun projectee  ->
    match projectee with
    | { job = __fname__job; callback = __fname__callback;_} -> __fname__job
let __proj__Mkjob__item__callback: 'a . 'a job -> 'a -> Prims.unit =
  fun projectee  ->
    match projectee with
    | { job = __fname__job; callback = __fname__callback;_} ->
        __fname__callback
type z3result =
  {
  z3result_status: z3status;
  z3result_time: Prims.int;
  z3result_statistics: z3statistics;
  z3result_query_hash: Prims.string FStar_Pervasives_Native.option;}[@@deriving
                                                                    show]
let __proj__Mkz3result__item__z3result_status: z3result -> z3status =
  fun projectee  ->
    match projectee with
    | { z3result_status = __fname__z3result_status;
        z3result_time = __fname__z3result_time;
        z3result_statistics = __fname__z3result_statistics;
        z3result_query_hash = __fname__z3result_query_hash;_} ->
        __fname__z3result_status
let __proj__Mkz3result__item__z3result_time: z3result -> Prims.int =
  fun projectee  ->
    match projectee with
    | { z3result_status = __fname__z3result_status;
        z3result_time = __fname__z3result_time;
        z3result_statistics = __fname__z3result_statistics;
        z3result_query_hash = __fname__z3result_query_hash;_} ->
        __fname__z3result_time
let __proj__Mkz3result__item__z3result_statistics: z3result -> z3statistics =
  fun projectee  ->
    match projectee with
    | { z3result_status = __fname__z3result_status;
        z3result_time = __fname__z3result_time;
        z3result_statistics = __fname__z3result_statistics;
        z3result_query_hash = __fname__z3result_query_hash;_} ->
        __fname__z3result_statistics
let __proj__Mkz3result__item__z3result_query_hash:
  z3result -> Prims.string FStar_Pervasives_Native.option =
  fun projectee  ->
    match projectee with
    | { z3result_status = __fname__z3result_status;
        z3result_time = __fname__z3result_time;
        z3result_statistics = __fname__z3result_statistics;
        z3result_query_hash = __fname__z3result_query_hash;_} ->
        __fname__z3result_query_hash
type z3job = z3result job[@@deriving show]
let job_queue: z3job Prims.list FStar_ST.ref = FStar_Util.mk_ref []
let pending_jobs: Prims.int FStar_ST.ref =
  FStar_Util.mk_ref (Prims.parse_int "0")
let with_monitor:
  'Auu____4081 'Auu____4082 .
    'Auu____4082 -> (Prims.unit -> 'Auu____4081) -> 'Auu____4081
  =
  fun m  ->
    fun f  ->
      FStar_Util.monitor_enter m;
      (let res = f () in FStar_Util.monitor_exit m; res)
let z3_job:
  Prims.bool ->
    FStar_SMTEncoding_Term.error_labels ->
      Prims.string ->
        Prims.string FStar_Pervasives_Native.option -> Prims.unit -> z3result
  =
  fun fresh  ->
    fun label_messages  ->
      fun input  ->
        fun qhash  ->
          fun uu____4115  ->
            let start = FStar_Util.now () in
            let uu____4119 =
              try doZ3Exe fresh input label_messages
              with
              | uu____4143 when
                  let uu____4144 = FStar_Options.trace_error () in
                  Prims.op_Negation uu____4144 ->
                  (bg_z3_proc.refresh ();
                   (let uu____4146 =
                      FStar_Util.smap_create (Prims.parse_int "0") in
                    ((UNKNOWN
                        ([],
                          (FStar_Pervasives_Native.Some
                             "Z3 raised an exception"))), uu____4146))) in
            match uu____4119 with
            | (status,statistics) ->
                let uu____4157 =
                  let uu____4162 = FStar_Util.now () in
                  FStar_Util.time_diff start uu____4162 in
                (match uu____4157 with
                 | (uu____4163,elapsed_time) ->
                     {
                       z3result_status = status;
                       z3result_time = elapsed_time;
                       z3result_statistics = statistics;
                       z3result_query_hash = qhash
                     })
let running: Prims.bool FStar_ST.ref = FStar_Util.mk_ref false
let rec dequeue': Prims.unit -> Prims.unit =
  fun uu____4180  ->
    let j =
      let uu____4182 = FStar_ST.op_Bang job_queue in
      match uu____4182 with
      | [] -> failwith "Impossible"
      | hd1::tl1 -> (FStar_ST.op_Colon_Equals job_queue tl1; hd1) in
    FStar_Util.incr pending_jobs;
    FStar_Util.monitor_exit job_queue;
    run_job j;
    with_monitor job_queue (fun uu____4307  -> FStar_Util.decr pending_jobs);
    dequeue ()
and dequeue: Prims.unit -> Prims.unit =
  fun uu____4309  ->
    let uu____4310 = FStar_ST.op_Bang running in
    if uu____4310
    then
      let rec aux uu____4362 =
        FStar_Util.monitor_enter job_queue;
        (let uu____4368 = FStar_ST.op_Bang job_queue in
         match uu____4368 with
         | [] ->
             (FStar_Util.monitor_exit job_queue;
              FStar_Util.sleep (Prims.parse_int "50");
              aux ())
         | uu____4429 -> dequeue' ()) in
      aux ()
    else ()
and run_job: z3job -> Prims.unit =
  fun j  ->
    let uu____4433 = j.job () in FStar_All.pipe_left j.callback uu____4433
let init: Prims.unit -> Prims.unit =
  fun uu____4436  ->
    FStar_ST.op_Colon_Equals running true;
    (let n_cores1 = FStar_Options.n_cores () in
     if n_cores1 > (Prims.parse_int "1")
     then
       let rec aux n1 =
         if n1 = (Prims.parse_int "0")
         then ()
         else (FStar_Util.spawn dequeue; aux (n1 - (Prims.parse_int "1"))) in
       aux n_cores1
     else ())
let enqueue: z3job -> Prims.unit =
  fun j  ->
    FStar_Util.monitor_enter job_queue;
    (let uu____4503 =
       let uu____4506 = FStar_ST.op_Bang job_queue in
       FStar_List.append uu____4506 [j] in
     FStar_ST.op_Colon_Equals job_queue uu____4503);
    FStar_Util.monitor_pulse job_queue;
    FStar_Util.monitor_exit job_queue
let finish: Prims.unit -> Prims.unit =
  fun uu____4624  ->
    let rec aux uu____4628 =
      let uu____4629 =
        with_monitor job_queue
          (fun uu____4645  ->
             let uu____4646 = FStar_ST.op_Bang pending_jobs in
             let uu____4695 =
               let uu____4696 = FStar_ST.op_Bang job_queue in
               FStar_List.length uu____4696 in
             (uu____4646, uu____4695)) in
      match uu____4629 with
      | (n1,m) ->
          if (n1 + m) = (Prims.parse_int "0")
          then FStar_ST.op_Colon_Equals running false
          else (FStar_Util.sleep (Prims.parse_int "500"); aux ()) in
    aux ()
type scope_t = FStar_SMTEncoding_Term.decl Prims.list Prims.list[@@deriving
                                                                  show]
let fresh_scope:
  FStar_SMTEncoding_Term.decl Prims.list Prims.list FStar_ST.ref =
  FStar_Util.mk_ref [[]]
let mk_fresh_scope: Prims.unit -> scope_t =
  fun uu____4838  -> FStar_ST.op_Bang fresh_scope
let bg_scope: FStar_SMTEncoding_Term.decl Prims.list FStar_ST.ref =
  FStar_Util.mk_ref []
let push: Prims.string -> Prims.unit =
  fun msg  ->
    (let uu____4912 =
       let uu____4917 = FStar_ST.op_Bang fresh_scope in
       [FStar_SMTEncoding_Term.Caption msg; FStar_SMTEncoding_Term.Push] ::
         uu____4917 in
     FStar_ST.op_Colon_Equals fresh_scope uu____4912);
    (let uu____5036 =
       let uu____5039 = FStar_ST.op_Bang bg_scope in
       FStar_List.append uu____5039
         [FStar_SMTEncoding_Term.Push; FStar_SMTEncoding_Term.Caption msg] in
     FStar_ST.op_Colon_Equals bg_scope uu____5036)
let pop: Prims.string -> Prims.unit =
  fun msg  ->
    (let uu____5150 =
       let uu____5155 = FStar_ST.op_Bang fresh_scope in
       FStar_List.tl uu____5155 in
     FStar_ST.op_Colon_Equals fresh_scope uu____5150);
    (let uu____5274 =
       let uu____5277 = FStar_ST.op_Bang bg_scope in
       FStar_List.append uu____5277
         [FStar_SMTEncoding_Term.Caption msg; FStar_SMTEncoding_Term.Pop] in
     FStar_ST.op_Colon_Equals bg_scope uu____5274)
let giveZ3: FStar_SMTEncoding_Term.decl Prims.list -> Prims.unit =
  fun decls  ->
    FStar_All.pipe_right decls
      (FStar_List.iter
         (fun uu___83_5395  ->
            match uu___83_5395 with
            | FStar_SMTEncoding_Term.Push  -> failwith "Unexpected push/pop"
            | FStar_SMTEncoding_Term.Pop  -> failwith "Unexpected push/pop"
            | uu____5396 -> ()));
    (let uu____5398 = FStar_ST.op_Bang fresh_scope in
     match uu____5398 with
     | hd1::tl1 ->
         FStar_ST.op_Colon_Equals fresh_scope ((FStar_List.append hd1 decls)
           :: tl1)
     | uu____5527 -> failwith "Impossible");
    (let uu____5532 =
       let uu____5535 = FStar_ST.op_Bang bg_scope in
       FStar_List.append uu____5535 decls in
     FStar_ST.op_Colon_Equals bg_scope uu____5532)
let refresh: Prims.unit -> Prims.unit =
  fun uu____5644  ->
    (let uu____5646 =
       let uu____5647 = FStar_Options.n_cores () in
       uu____5647 < (Prims.parse_int "2") in
     if uu____5646 then bg_z3_proc.refresh () else ());
    (let uu____5649 =
       let uu____5652 =
         let uu____5657 = FStar_ST.op_Bang fresh_scope in
         FStar_List.rev uu____5657 in
       FStar_List.flatten uu____5652 in
     FStar_ST.op_Colon_Equals bg_scope uu____5649)
let mk_input:
  FStar_SMTEncoding_Term.decl Prims.list ->
    (Prims.string,Prims.string FStar_Pervasives_Native.option)
      FStar_Pervasives_Native.tuple2
  =
  fun theory  ->
    let options = z3_options () in
    let uu____5786 =
      let uu____5793 =
        (FStar_Options.record_hints ()) ||
          ((FStar_Options.use_hints ()) && (FStar_Options.use_hint_hashes ())) in
      if uu____5793
      then
        let uu____5800 =
          let uu____5811 =
            FStar_All.pipe_right theory
              (FStar_Util.prefix_until
                 (fun uu___84_5839  ->
                    match uu___84_5839 with
                    | FStar_SMTEncoding_Term.CheckSat  -> true
                    | uu____5840 -> false)) in
          FStar_All.pipe_right uu____5811 FStar_Option.get in
        match uu____5800 with
        | (prefix1,check_sat,suffix) ->
            let pp =
              FStar_List.map (FStar_SMTEncoding_Term.declToSmt options) in
            let pp_no_cap =
              FStar_List.map
                (FStar_SMTEncoding_Term.declToSmt_no_caps options) in
            let suffix1 = check_sat :: suffix in
            let ps_lines = pp prefix1 in
            let ss_lines = pp suffix1 in
            let ps = FStar_String.concat "\n" ps_lines in
            let ss = FStar_String.concat "\n" ss_lines in
            let uncaption uu___85_5918 =
              match uu___85_5918 with
              | FStar_SMTEncoding_Term.Caption uu____5919 ->
                  FStar_SMTEncoding_Term.Caption ""
              | FStar_SMTEncoding_Term.Assume a ->
                  FStar_SMTEncoding_Term.Assume
                    (let uu___90_5923 = a in
                     {
                       FStar_SMTEncoding_Term.assumption_term =
                         (uu___90_5923.FStar_SMTEncoding_Term.assumption_term);
                       FStar_SMTEncoding_Term.assumption_caption =
                         FStar_Pervasives_Native.None;
                       FStar_SMTEncoding_Term.assumption_name =
                         (uu___90_5923.FStar_SMTEncoding_Term.assumption_name);
                       FStar_SMTEncoding_Term.assumption_fact_ids =
                         (uu___90_5923.FStar_SMTEncoding_Term.assumption_fact_ids)
                     })
              | FStar_SMTEncoding_Term.DeclFun (n1,a,s,uu____5927) ->
                  FStar_SMTEncoding_Term.DeclFun
                    (n1, a, s, FStar_Pervasives_Native.None)
              | FStar_SMTEncoding_Term.DefineFun (n1,a,s,b,uu____5940) ->
                  FStar_SMTEncoding_Term.DefineFun
                    (n1, a, s, b, FStar_Pervasives_Native.None)
              | d -> d in
            let hs =
              let uu____5951 =
                let uu____5954 =
                  let uu____5957 =
                    FStar_All.pipe_right prefix1 (FStar_List.map uncaption) in
                  FStar_All.pipe_right uu____5957 pp_no_cap in
                FStar_All.pipe_right uu____5954
                  (FStar_List.filter (fun s  -> s <> "")) in
              FStar_All.pipe_right uu____5951 (FStar_String.concat "\n") in
            let uu____5976 =
              let uu____5979 = FStar_Util.digest_of_string hs in
              FStar_Pervasives_Native.Some uu____5979 in
            ((Prims.strcat ps (Prims.strcat "\n" ss)), uu____5976)
      else
        (let uu____5983 =
           let uu____5984 =
             FStar_List.map (FStar_SMTEncoding_Term.declToSmt options) theory in
           FStar_All.pipe_right uu____5984 (FStar_String.concat "\n") in
         (uu____5983, FStar_Pervasives_Native.None)) in
    match uu____5786 with
    | (r,hash) ->
        ((let uu____6004 = FStar_Options.log_queries () in
          if uu____6004 then query_logging.write_to_log r else ());
         (r, hash))
type cb = z3result -> Prims.unit[@@deriving show]
let cache_hit:
  Prims.string FStar_Pervasives_Native.option ->
    Prims.string FStar_Pervasives_Native.option -> cb -> Prims.bool
  =
  fun cache  ->
    fun qhash  ->
      fun cb  ->
        let uu____6029 =
          (FStar_Options.use_hints ()) && (FStar_Options.use_hint_hashes ()) in
        if uu____6029
        then
          match qhash with
          | FStar_Pervasives_Native.Some x when qhash = cache ->
              let stats = FStar_Util.smap_create (Prims.parse_int "0") in
              (FStar_Util.smap_add stats "fstar_cache_hit" "1";
               (let result =
                  {
                    z3result_status = (UNSAT FStar_Pervasives_Native.None);
                    z3result_time = (Prims.parse_int "0");
                    z3result_statistics = stats;
                    z3result_query_hash = qhash
                  } in
                cb result; true))
          | uu____6040 -> false
        else false
let ask_1_core:
  (FStar_SMTEncoding_Term.decls_t ->
     (FStar_SMTEncoding_Term.decls_t,Prims.bool)
       FStar_Pervasives_Native.tuple2)
    ->
    Prims.string FStar_Pervasives_Native.option ->
      FStar_SMTEncoding_Term.error_labels ->
        FStar_SMTEncoding_Term.decls_t -> cb -> Prims.unit
  =
  fun filter_theory  ->
    fun cache  ->
      fun label_messages  ->
        fun qry  ->
          fun cb  ->
            let theory =
              let uu____6081 = FStar_ST.op_Bang bg_scope in
              FStar_List.append uu____6081
                (FStar_List.append [FStar_SMTEncoding_Term.Push]
                   (FStar_List.append qry [FStar_SMTEncoding_Term.Pop])) in
            let uu____6136 = filter_theory theory in
            match uu____6136 with
            | (theory1,used_unsat_core) ->
                let uu____6143 = mk_input theory1 in
                (match uu____6143 with
                 | (input,qhash) ->
                     (FStar_ST.op_Colon_Equals bg_scope [];
                      (let uu____6209 =
                         let uu____6210 = cache_hit cache qhash cb in
                         Prims.op_Negation uu____6210 in
                       if uu____6209
                       then
                         run_job
                           {
                             job = (z3_job false label_messages input qhash);
                             callback = cb
                           }
                       else ())))
let ask_n_cores:
  (FStar_SMTEncoding_Term.decls_t ->
     (FStar_SMTEncoding_Term.decls_t,Prims.bool)
       FStar_Pervasives_Native.tuple2)
    ->
    Prims.string FStar_Pervasives_Native.option ->
      FStar_SMTEncoding_Term.error_labels ->
        FStar_SMTEncoding_Term.decls_t ->
          scope_t FStar_Pervasives_Native.option -> cb -> Prims.unit
  =
  fun filter_theory  ->
    fun cache  ->
      fun label_messages  ->
        fun qry  ->
          fun scope  ->
            fun cb  ->
              let theory =
                let uu____6260 =
                  match scope with
                  | FStar_Pervasives_Native.Some s -> FStar_List.rev s
                  | FStar_Pervasives_Native.None  ->
                      (FStar_ST.op_Colon_Equals bg_scope [];
                       (let uu____6325 = FStar_ST.op_Bang fresh_scope in
                        FStar_List.rev uu____6325)) in
                FStar_List.flatten uu____6260 in
              let theory1 =
                FStar_List.append theory
                  (FStar_List.append [FStar_SMTEncoding_Term.Push]
                     (FStar_List.append qry [FStar_SMTEncoding_Term.Pop])) in
              let uu____6391 = filter_theory theory1 in
              match uu____6391 with
              | (theory2,used_unsat_core) ->
                  let uu____6398 = mk_input theory2 in
                  (match uu____6398 with
                   | (input,qhash) ->
                       let uu____6411 =
                         let uu____6412 = cache_hit cache qhash cb in
                         Prims.op_Negation uu____6412 in
                       if uu____6411
                       then
                         enqueue
                           {
                             job = (z3_job true label_messages input qhash);
                             callback = cb
                           }
                       else ())
let ask:
  (FStar_SMTEncoding_Term.decls_t ->
     (FStar_SMTEncoding_Term.decls_t,Prims.bool)
       FStar_Pervasives_Native.tuple2)
    ->
    Prims.string FStar_Pervasives_Native.option ->
      FStar_SMTEncoding_Term.error_labels ->
        FStar_SMTEncoding_Term.decl Prims.list ->
          scope_t FStar_Pervasives_Native.option -> cb -> Prims.unit
  =
  fun filter1  ->
    fun cache  ->
      fun label_messages  ->
        fun qry  ->
          fun scope  ->
            fun cb  ->
              let uu____6461 =
                let uu____6462 = FStar_Options.n_cores () in
                uu____6462 = (Prims.parse_int "1") in
              if uu____6461
              then ask_1_core filter1 cache label_messages qry cb
              else ask_n_cores filter1 cache label_messages qry scope cb