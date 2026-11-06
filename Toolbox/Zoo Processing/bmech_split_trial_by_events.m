function bmech_split_trial_by_events(fld, first_start_event, first_end_event)
% BMECH_SPLIT_TRIAL_BY_EVENTS Split trials using two event sequences.
%
% Example:
%   bmech_split_trial_by_events(fld, 'water_exit_1', 'flip_2')
%
% Produces:
%   water_exit_1 -> flip_2
%   water_exit_2 -> flip_3
%   water_exit_3 -> flip_4
%   ...

fl = engine('fld', fld, 'extension', 'zoo');

[start_name, start_num] = split_event_name(first_start_event);
[end_name, end_num] = split_event_name(first_end_event);

for i = 1:length(fl)

    batchdisp(fl{i}, 'extracting cycles')

    [fpath, fname, ext] = fileparts(fl{i});

    data = zload(fl{i});

    j = 0;

    while true

        start_event = [start_name, num2str(start_num + j)];
        end_event = [end_name, num2str(end_num + j)];

        if ~event_exists(data, start_event) || ...
                ~event_exists(data, end_event)
            break
        end

        disp(['...', start_event, ' to ', end_event])

        data_new = split_trial_data( ...
            data, ...
            start_event, ...
            end_event ...
            );

        if ~isempty(data_new)

            fname_cycle = fullfile( ...
                fpath, ...
                [fname, '_cycle_', num2str(j + 1), ext] ...
                );

            zsave(fname_cycle, data_new)

        end

        j = j + 1;

    end
end
end


function [event_name, event_num] = split_event_name(event)
% Split 'water_exit_1' into 'water_exit_' and 1.

tokens = regexp(event, '^(.*?)(\d+)$', 'tokens', 'once');

if isempty(tokens)
    error('Event name must end with a number.')
end

event_name = tokens{1};
event_num = str2double(tokens{2});
end


function tf = event_exists(data, event_name)
% Check whether an event exists in any zoo channel.

tf = false;

chns = setdiff(fieldnames(data), 'zoosystem');

for i = 1:length(chns)

    if isfield(data.(chns{i}), 'event') && ...
            isstruct(data.(chns{i}).event) && ...
            isfield(data.(chns{i}).event, event_name)

        tf = true;
        return
    end
end
end