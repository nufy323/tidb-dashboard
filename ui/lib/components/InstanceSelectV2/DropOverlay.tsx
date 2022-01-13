import React, { useState, useMemo } from 'react'
import { AntCheckboxGroupHeader } from '../'
import { IColumn, ISelection } from 'office-ui-fabric-react/lib/DetailsList'
import { filterComponentsList } from '@lib/utils/instanceTable'
import { useTranslation } from 'react-i18next'
import TableWithFilter, { ITableWithFilterRefProps } from './TableWithFilter'
import { TopoCompInfoWithSignature } from '@lib/client'

const groupProps = {
  onRenderHeader: (props) => <AntCheckboxGroupHeader {...props} />,
}

export interface IDropOverlayProps {
  selection: ISelection
  columns: IColumn[]
  items: TopoCompInfoWithSignature[]
  getKey?: (item: any, index?: number) => string
  filterTableRef?: React.Ref<ITableWithFilterRefProps>
  containerProps?: React.HTMLAttributes<HTMLDivElement>
}

function DropOverlay({
  selection,
  columns,
  items,
  getKey,
  filterTableRef,
  containerProps,
}: IDropOverlayProps) {
  const { t } = useTranslation()
  const [keyword, setKeyword] = useState('')

  const [finalItems, finalGroups] = useMemo(() => {
    return filterComponentsList(items, keyword)
  }, [items, keyword])

  const { style: containerStyle, ...restContainerProps } = containerProps ?? {}
  const finalContainerProps = useMemo(() => {
    const style: React.CSSProperties = {
      fontSize: '0.8rem',
      ...containerStyle,
    }
    return {
      style,
      ...restContainerProps,
    } as React.HTMLAttributes<HTMLDivElement> & Record<string, string>
  }, [containerStyle, restContainerProps])

  return (
    <TableWithFilter
      selection={selection}
      getKey={getKey}
      filterPlaceholder={t('component.instanceSelectV2.filterPlaceholder')}
      filter={keyword}
      onFilterChange={setKeyword}
      tableMaxHeight={300}
      tableWidth={400}
      columns={columns}
      items={finalItems}
      groups={finalGroups}
      groupProps={groupProps}
      containerProps={finalContainerProps}
      ref={filterTableRef}
    />
  )
}

export default React.memo(DropOverlay)
