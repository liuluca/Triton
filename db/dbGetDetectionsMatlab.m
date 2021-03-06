function [timestamps, EndP, info] = dbGetDetectionsMatlab(queryEngine, varargin)
% [timestamps, endPredicate, deploymentIdx, deployments] = dbGetDetections(queryEngine, Optional Args)
% Retrieve detections meeting criteria from database.  Detections
% are returned as a timestamps matrix of Matlab serial dates (see
% datenum).  The timestamps will either be single times that represent
% a detection within a binned interval, or span a time interval.  If the
% bin interval time is desired, sue the 'Duration' parameter that is
% documented below.
%
% The optional endP return value allows callers to distinguish between
% interval and instantaneous detections.  Its usage is described at the
% example at the end of this help.
%
% The optional output info is a structure variable.  If requested, it
% contains the following fields:
%   deployments - An array of structures that can be used to identify
%       the deployments associated with the retrieved detections.
%   deploymentIdx - A vector with the same number of rows as detections
%       returned (number of rows in timestamps).  Each item is an index
%       into the deployments array indicating which deployment the
%       detection originated from.
%   Other fields may be populated based on parameters passed to the
%       optional input 'Return'
%
% Inputs:
% queryEngine must be a Tethys database query object, see dbDemo() for an
% example of how to create one.
%
% To query for specific types of detections, use any combination of the
% following keyword/value pairs:
%
% Attributes associated with project metadata:
% 'Project', string - Name of project data is associated with
% 'Site', string - name of location where data was collected
% 'Deployment', comparison - Which deployment of sensor at a given location
%
% Attributes associated with how detections were made:
% 'Effort', ('On') | 'Off', Specify effort type. Query time may slow down
%                           if using 'Off'.
% 'Method', string - Method of detection
%           e.g. analyst, Spectrogram Correlation
% 'Software', string - Name of detector, e.g. analyst, silbido
% 'Version', string - What version of the detector
% 'UserDefined' - used to specify UserDefined parameters. 
% 'UserID', string - User responsible for the analysis
%
% 'Effort/Start'|'Effort/End', string comparison - Specify start and or end of
%       detection effort.  Note that this is a direct comparison to the
%       effort start or end, not to the interval.  As an example,
%       effort between 2015-01-01T00:00:00Z and 2015-03-0112:00:00Z would
%       not be picked up if with Effort/Start, {'>=', '2015-02-01T00:00:00Z'}
%       as this is after the start of the deployment.
%
% Attributes associated with detections
% 'SpeciesID', string  - species or category of sound
% 'Group', string - species group e.g. BW43
% 'Call', string - type of call/sound
% 'Subtype', string - subtype of call
%
% Comparison consists of either a:
%   scalar - queries for equality
%   cell array {operator, scalar} - Operator is a relational
%       operator in {'=', '<', '<=', '>', '>='} which is compared
%       to the specified scalar.
%
% One can also query for detections froma specific document by using the
%  document id in the detections collection:
% 'Document', DocID - DocId is 'dbxml:///Detections/document_name'
%     At the time of this writing, document names are derived from the
%     source spreadsheet name.
%
% Other optional arguments:
% 'Return', string - Return an additional field, e.g.
%   'Return', 'File'
% 'Duration', N - When present, detections without a stop time
%    are interpreted as having fixed duration, and the end
%    time is set to start time + N.  (Default N=0)
%    Example:  60 m duration:  'Duration', datenum([0 0 0 1 0 0])
%    Note that when duration is set, two columns will always be
%    returned, even if there are no end times in the requested
%    detections.
% 'ShowQuery', true|false (Default)- Display the constructed XQuery
%
% Example:  Retrieve all detections for Pacific white-sided dolphins
% from Southern California regardless of project.  Note that when
% multiple attirbutes are specified, all criterai must be satisfied.
% [detections, endP] = dbGetDetections(qengine, ...
%                         'Project', 'SOCAL', 'Species', 'Lo');
%
% Output is a one or two column matrix of start and (if available) end
% times of detections.  If the result contains instantaneous detections
% and two columns are returned due to interval detections also being
% present, the time end predicate (endP) can be used to determine
% which is which.  Where endP(row_idx) = 1, detections(row_idx, :) will
% be an interval detection.  Accordingly, a 0 indicates an instantaneous
% detection.
% Example: [detections, endP] = dbGetDetections(...);
% Interval detections: detections(endP, :)
% Instantaneous detections:  detections(~endP, 1)

event_duration = 0;
meta_conditions = '';  % selection criteria for detection meta data
det_conditions = '';  % selection criteria for detections
return_elements = {}; % List of additional elements that will be returned
show_query = false; % do not display XQuery
effort = 'OnEffort';
benchmark = false;
idx=1;
% condition prefix/cojunction
% First time used contains where to form the where clause.
% On subsequent uses it is changed to the conjunction and
conj_meta = 'where';
conj_det = 'where';
while idx < length(varargin)
    switch varargin{idx}
        case 'Document'
            comparison = sprintf('base-uri($det) = "%s"', varargin{idx+1});
            meta_conditions = sprintf('%s%s %s', ...
                meta_conditions, conj_meta, comparison);
            conj_meta = ' and';
            idx = idx+2;
        case {'Method', 'Software', 'Version'}
            meta_conditions = ...
                sprintf('%s%s upper-case($det/Algorithm/%s) = upper-case("%s")', ...
                meta_conditions, conj_meta, varargin{idx}, varargin{idx+1});
            conj_meta = ' and';
            idx = idx+2;
        case 'UserID'
            meta_conditions = sprintf('%s%s $det/%s = "%s"', ...
                meta_conditions, conj_meta, ...
                varargin{idx}, varargin{idx+1});
            conj_meta = ' and';
            idx = idx+2;
            % DataSource details
        case {'Project', 'Site'}
            field = sprintf('$det/DataSource/%s', varargin{idx});
            meta_conditions = ...
                sprintf('%s%s %s', ...
                meta_conditions, conj_meta, dbListMemberOp(field, varargin{idx+1}));
            conj_meta = ' and';
            idx = idx+2;
        case 'Deployment'
            comparison = dbRelOp(varargin{idx}, '$det/DataSource/%s', varargin{idx+1});
            meta_conditions = sprintf('%s%s %s', ...
                meta_conditions, conj_meta, comparison);
            conj_meta = ' and';
            idx = idx+2;
        case 'QualityAssurance'
            %if true, check exists
            if varargin{idx+1} == true
                meta_conditions = sprintf('%s%s exists($det/%s) and not(number(lib:if-empty($det/%s/Description,0)) = 0)', ...
                    meta_conditions, conj_meta, ...
                    varargin{idx},varargin{idx});
            else %otherwise, not exists
                meta_conditions = sprintf('%s%s (not(exists($det/%s)) or number(lib:if-empty($det/%s/Description,0)) = 0)', ...
                    meta_conditions, conj_meta, ...
                    varargin{idx},varargin{idx});
            end
            conj_meta = ' and';
            idx = idx+2;
        case { 'Effort/Start', 'Effort/End'}
            comparison = dbRelOpChar(varargin{idx}, ...
                '$det/%s', varargin{idx+1}, false);
            meta_conditions = sprintf('%s%s %s', ...
                meta_conditions, conj_meta, comparison);
            conj_meta = ' and';
            idx = idx+2;
        case {'Effort'}
            % detections after this are 'On' effort, 'Off' effort, or
            % both *
            switch varargin{idx+1}
                case 'On', effort='OnEffort';
                case 'Off', effort='OffEffort';
                case {'Both', '*'}, effort='*';
                otherwise
                    error('Bad effort specifciation');
            end
            idx=idx+2;
        case 'Granularity'
            field = sprintf('$det/Effort/Kind/%s',varargin{idx});
            meta_conditions = ...
                sprintf('%s%s %s',...
                meta_conditions,conj_meta,dbListMemberOp(field,varargin{idx+1}));
            conj_meta = ' and';
            idx=idx+2;
        case 'BinSize_m'
            field = sprintf('$det/Effort/Kind/Granularity/@%s = "%.1f"',...
                varargin{idx},varargin{idx+1});
            meta_conditions = ...
                sprintf('%s%s %s',...
                meta_conditions,conj_meta,field);
            conj_meta = ' and';
            idx=idx+2;
        case 'SpeciesID'
            if benchmark
                spID = varargin{idx+1};
            end
            varargin{idx+1} = sprintf(dbSpeciesFmt('GetInput'), varargin{idx+1});
            %if OnEffort, use meta_conditions as well
            if strcmp(effort,'OnEffort')
                field = sprintf('$det/Effort/Kind/%s = %s',...
                    varargin{idx},varargin{idx+1});
                meta_conditions = ...
                    sprintf('%s%s %s',...
                    meta_conditions,conj_meta,field);
            end
            det_conditions = ...
                sprintf('%s%s $detection/%s = %s', ...
                det_conditions, conj_det, ...
                varargin{idx}, varargin{idx+1});
            conj_det = ' and';
            idx = idx + 2;
        case {'Group'}
            %if OnEffort, use meta_conditions as well
            if strcmp(effort,'OnEffort')
                field = sprintf('$det/Effort/Kind/SpeciesID/@%s = "%s"',...
                    varargin{idx},varargin{idx+1});
                meta_conditions = ...
                    sprintf('%s%s %s',...
                    meta_conditions,conj_meta,field);
            end
            det_conditions = ...
                sprintf('%s%s $detection/SpeciesID/@%s = "%s"', ...
                det_conditions, conj_det, varargin{idx}, varargin{idx+1});
            conj_det = ' and';
            idx = idx+2;
        case {'Call'}
            if benchmark
                spCall = varargin{idx+1};
            end
            %if OnEffort, use meta_conditions as well
            if strcmp(effort,'OnEffort')
                field = sprintf('$det/Effort/Kind/%s = "%s"',...
                    varargin{idx},varargin{idx+1});
                meta_conditions = ...
                    sprintf('%s%s %s',...
                    meta_conditions,conj_meta,field);
            end
            det_conditions = ...
                sprintf('%s%s $detection/%s = "%s"', ...
                det_conditions, conj_det, varargin{idx}, varargin{idx+1});
            conj_det = ' and';
            idx = idx+2;
        case 'UserDefined'
            name = varargin{idx+1}{1};
            value = varargin{idx+1}{2};
            if ischar(value)
                det_conditions =...
                    sprintf('%s%s $detection/Parameters/UserDefined/%s = "%s"',...
                    det_conditions, conj_det, name,value);
            else
                det_conditions =...
                sprintf('%s%s number($detection/Parameters/UserDefined/%s) = %d',...
                    det_conditions, conj_det, name,value);
            end
            conj_det = ' and';
            idx = idx+2;
        case {'Subtype'}
            %if OnEffort, use meta_conditions as well
            if strcmp(effort,'OnEffort')
                field = sprintf('$det/Effort/Kind/Parameters/%s = "%s"',...
                    varargin{idx},varargin{idx+1});
                meta_conditions = ...
                    sprintf('%s%s %s',...
                    meta_conditions,conj_meta,field);
            end
            det_conditions = ...
                sprintf('%s%s $detection/Parameters/%s = "%s"', ...
                det_conditions, conj_det, varargin{idx}, varargin{idx+1});
            conj_det = ' and';
            idx = idx+2;
        case 'Comment'
            det_conditions = ...
                sprintf('%s%s $detection/%s = "%s"', ...
                det_conditions, conj_det, varargin{idx}, varargin{idx+1});
            conj_det = ' and';
            idx = idx+2;
        case {'Score'}
            comparison = dbRelOp(varargin{idx}, '$detection/Parameters/%s', varargin{idx+1});
            det_conditions = ...
                sprintf('%s%s %s', ...
                det_conditions, conj_det,comparison);
            conj_det = ' and';
            idx = idx+2;
        case 'Duration'
            event_duration = varargin{idx+1};
            if ~ isscalar(event_duration)
                error('%s must be scalar', varargin{idx+1})
            end
            idx = idx+2;
        case 'Return'
            % Provide additional return values
            return_elements{end+1} = varargin{idx+1};
            idx=idx+2;
        case 'ShowQuery'
            show_query = varargin{idx+1};
            idx = idx+2;
        case 'Benchmark'
            bench_path=varargin{idx+1};
            benchmark = true;
            idx = idx+2;
        otherwise
            error('Bad arugment:  %s', varargin{idx});
    end
end

query_str = dbGetCannedQuery('GetDetections.xq');

source = 'collection("Detections")/ty:Detections';
if length(return_elements) > 0
    additional_info = sprintf('{$detection/%s}\n', return_elements{:});
else
    additional_info = '';
end
query = sprintf(query_str, source, meta_conditions, effort, ...
    det_conditions, additional_info);

% Display XQuery
if show_query
    fprintf(query);
end

%Execute XQuery
tic
dom = queryEngine.QueryReturnDoc(query);
q_elapsed = toc;
info.elapsed.query = q_elapsed;
fprintf('Query elapsed_s: %.03f\n',q_elapsed)

%time it
if benchmark
    tic;
end

% Assume only start times until we know better
EndP = [];

% Retrieve detection records from document model
if isempty(dom)
    timestamps = [];
    deploymentIdx = [];
    deployments = [];
else
    [timestamps, missingP] = dbParseDates(dom);
    EndCount = sum( ~missingP(:,end));
    
    if EndCount == 0
        % No end times were detected
        if event_duration == 0
            timestamps(:, 2) = [];  % No duration, remove end time
        else
            % Set interval to specified duration
            % Note that there is no guarantee that this will not create
            % overlapping events.
            timestamps(:, 2) = timestamps(:, 1) + event_duration;
        end
    end
    
    if nargout > 2
        indices = dom.item(0).getElementsByTagName('idx');
        indicesN = indices.getLength();
        info.deploymentIdx = zeros(indicesN, 1);
        for idx=1:indicesN
            info.deploymentIdx(idx) = str2double(indices.item(idx-1).getFirstChild().getNodeValue());
        end
        depdom = dbXPathDomQuery(dom, 'ty:Result/Sources');
        deploymentsN = depdom.item(0).getLength();
        info.deployments = struct('EnsembleName', cell(deploymentsN,1), 'Project', cell(deploymentsN,1), 'Deployment', cell(deploymentsN,1), 'Site', cell(deploymentsN,1), 'Cruise', cell(deploymentsN,1));
        for idx = 1:deploymentsN
            item = depdom.item(0).item(idx-1);
            for childidx = 1:item.getLength()
                child = item.item(childidx-1);
                field = char(child.getNodeName());
                if strcmp(field, '#text')  % we don't care about extraneous text
                    continue
                end
                value = char(child.getFirstChild().getNodeValue());
                dvalue = str2double(value);
                if ~ isnan(dvalue)
                    value = dvalue;
                end
                info.deployments(idx).(field) = value;
            end
        end
        
        N = size(timestamps, 1);
        warnings = {};
        if length(return_elements) > 0
            % Pull out detections, should have N entries
            detdom = dbXPathDomQuery(dom, 'ty:Result/Detections/Detection');
            assert(detdom.getLength() == N, 'Number of detections and detection info do not match')
            
            % Map return elements to the field names that will be returned.
            fieldnm = regexprep(return_elements, '.*/([^/]+$)', '$1');
            for idx = 1:length(fieldnm)
                info.(fieldnm{idx}) = cell(N, 1);
            end
            % Populate
            for idx = 1:N
                entrydom = detdom.item(idx-1);
                for fidx = 1:length(fieldnm)
                    itemdom = dbXPathDomQuery(entrydom, fieldnm{fidx});
                    if itemdom.getLength() > 0
                        item0 = itemdom.item(0);
                        info.(fieldnm{fidx}){idx} = ...
                            char(item0.getFirstChild().getNodeValue());
                    end
                end
            end
        end
    end
    if benchmark && ~isempty(timestamps)
        elapsed = toc;
        fprintf('Parsing elapsed_s: %.03f\n',elapsed);
        info.elapsed.parse = elapsed;
        bench_file = fullfile(bench_path,...
            sprintf('%s_detections.txt',datestr(today(),'yyyy-mm-dd')));
        bench_fid=fopen(bench_file,'at');
        summary_file=(fullfile(bench_path,'1detection_summary.txt'));
        summ_fid = fopen(summary_file,'at');
        %TODO - make project/site/deployment variables
        fprintf(bench_fid,'%s%02d%s Query %s:\n"""\n%s.%s\n---omitting xq--\n"""\n>>%.3fs elapsed, %d detections\n\n',varargin{2},varargin{6},varargin{4},datestr(now(),'yyyy-mm-ddTHH:MM:SS.FFF-0700'),spID,spCall,elapsed,length(timestamps));
        fprintf(summ_fid,'%s...%s%02d%s %.3f_s >>%d_%s.%s,\n', datestr(now(),'yyyy-mm-ddTHH:MM:SS.FFF-0700'),varargin{2},varargin{6},varargin{4},elapsed,length(timestamps),spID,spCall);
        fclose(bench_fid);
        fclose(summ_fid);
    end
    
    
end
